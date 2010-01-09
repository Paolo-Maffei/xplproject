Option Strict On
Imports System
Imports System.Net

Friend Class SMSinterface

    ''' <summary>
    ''' The URL to request to activate sending a message.
    ''' </summary>
    ''' <remarks>Use <c>MsgPlaceholder</c>value as a marker where the actual message text to send needs to be inserted.</remarks>
    Public Shared URLmessage As String = "http://www.spryng.nl/SyncTextService?OPERATION=creditamount&USERNAME=henk&PASSWORD=weetnie"
    ''' <summary>
    ''' A string value to look for in the results returned from the HTTP request to <c>URLmessage</c>
    ''' </summary>
    ''' <remarks>This can be either a string for success or a string for failure, use <c>LookForSuccess</c> 
    ''' to specify the type</remarks>
    Public Shared LookFor As String = "<success>True"
    ''' <summary>
    ''' Determines whether finding the <c>LookFor</c> value in the results of the HTTP request to 
    ''' <c>URLmessage</c> indicates success or failure.
    ''' </summary>
    ''' <remarks>If <c>LookForSuccess = True</c> then finding the value <c>LookFor</c> in the results of 
    ''' the HTTP request to <c>URLmessage</c> indicates SUCCESS.</remarks>
    Public Shared LookForSuccess As Boolean = True
    ''' <summary>
    ''' The URL to request to get the remaining credits
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared URLcredits As String = "http://www.spryng.nl/SyncTextService?OPERATION=creditamount&USERNAME=henk&PASSWORD=weetnie"
    ''' <summary>
    ''' The delimiter specifying the start of the credits value in the results of the HTTP request to
    ''' <c>URLcredits</c>.
    ''' </summary>
    ''' <remarks>Example; if an XML is returned with in its body somewhere "&lt;credits&gt;67&lt;/credits&gt;", indicating 
    ''' that 67 credits are remaining, then the <c>DelimStart</c> value should be "&lt;credits&gt;" and 
    ''' the <c>DelimEnd</c> value should be "&lt;/credits&gt;".</remarks>
    Public Shared DelimStart As String = ""
    ''' <summary>
    ''' The delimiter specifying the end of the credits value in the results of the HTTP request to
    ''' <c>URLcredits</c>.
    ''' </summary>
    ''' <remarks>Example; if an XML is returned with in its body somewhere "&lt;credits&gt;67&lt;/credits&gt;", indicating 
    ''' that 67 credits are remaining, then the <c>DelimStart</c> value should be "&lt;credits&gt;" and 
    ''' the <c>DelimEnd</c> value should be "&lt;/credits&gt;".</remarks>
    Public Shared DelimEnd As String = ""
    ''' <summary>
    ''' Last result returned from sending a message, either <c>True</c> or <c>False</c>
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared LastResult As Boolean = False
    ''' <summary>
    ''' Last error returned from executing a HTTP request (either URLcredits or URLmessage)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared LastError As String = ""
    ''' <summary>
    ''' Last result from requesting the credits
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared LastCredits As String = ""
    ''' <summary>
    ''' The placeholder in the <c>URLmessage</c> value that is to be substituted by the actual message text.
    ''' </summary>
    ''' <remarks>This setting is case insensitive</remarks>
    Public Shared MsgPlaceholder As String = "[[MESSAGE]]"
    ''' <summary>
    ''' The placeholder in the <c>URLmessage</c> value that is to be substituted by the recipient value.
    ''' </summary>
    ''' <remarks>This setting is case insensitive</remarks>
    Public Shared RecipPlaceHolder As String = "[[RECIPIENT]]"
    Private Shared pMutex As New Threading.Mutex

    ''' <summary>
    ''' Sends an SMS message using a HTTP request
    ''' </summary>
    ''' <param name="Message">Message to be sent</param>
    ''' <returns><c>True</c> if success (see <seealso>LookFor</seealso> and <seealso>LookForSuccess</seealso>)</returns>
    ''' <remarks>Vaues must be set for <seealso>URLmessage</seealso>, <seealso>LookFor</seealso>, 
    ''' <seealso>LookForSuccess</seealso> and <seealso>MsgPlaceHolder</seealso></remarks>
    Public Shared Function SMSsend(ByVal Message As String, ByVal Recipient As String) As Boolean
        Dim myUrl As String
        Dim strResult As String = ""
        Dim n As Integer
        Dim err As String = ""
        Dim result As Boolean = False

        ' URLEncode contents
        Message = System.Web.HttpUtility.UrlEncode(Message)
        Recipient = System.Web.HttpUtility.UrlEncode(Recipient)

        ' replace placeholder with actual message
        myUrl = URLmessage
        n = InStr(myUrl.ToLower, MsgPlaceholder.ToLower)
        If n = 0 Then
            err = "Placeholder '" & MsgPlaceholder & "' not found in URL for sending a message."
        Else
            myUrl = Left(myUrl, n - 1) & Message & Mid(myUrl, n + Len(MsgPlaceholder))
            ' replace placeholder with recipient
            n = InStr(myUrl.ToLower, RecipPlaceHolder.ToLower)
            If n = 0 Then
                err = "Placeholder '" & RecipPlaceHolder & "' not found in URL for sending a message."
            Else
                myUrl = Left(myUrl, n - 1) & Recipient & Mid(myUrl, n + Len(RecipPlaceHolder))
                ' Execute
                Try
                    strResult = ExecHttp(myUrl)
                Catch ex As Exception
                    err = ex.Message
                End Try
                ' Digest results
                If InStr(strResult.ToLower, LookFor.ToLower) <> 0 Then
                    result = LookForSuccess
                Else
                    result = Not LookForSuccess
                End If

                If Not result Then
                    ' we had an error in the returned HTTP results
                    err = strResult
                End If
            End If
        End If
        ' consolidate results
        If err <> "" Then
            LastError = err
        End If
        LastResult = result

        Return LastResult
    End Function

    ''' <summary>
    ''' Gets the remaining credits using a HTTP request
    ''' </summary>
    ''' <returns><c>True</c> if the HTTP request was succesfull</returns>
    ''' <remarks>Afterwards <see cref="LastCredits"/> will contain the credits value retreived. Values must be set for <seealso>URLcredits</seealso>, <seealso>DelimStart</seealso> and 
    ''' <seealso>DelimEnd</seealso></remarks>
    Public Shared Function Credits() As Boolean
        Dim strResult As String = ""
        Dim result As Boolean = True
        Dim n As Integer
        ' Execute
        Try
            strResult = ExecHttp(URLcredits)
        Catch ex As Exception
            LastError = ex.Message
            result = False
        End Try
        ' Digest results
        If result Then
            If DelimStart <> "" Then
                n = InStr(strResult, DelimStart)
                If n <> 0 Then
                    ' remove anything before the delimiter and the delimiter itself
                    strResult = Mid(strResult, n + Len(DelimStart))
                End If
            End If
            If DelimEnd <> "" Then
                n = InStr(strResult, DelimEnd)
                If n <> 0 Then
                    ' remove anything after the delimiter and the delimiter itself
                    strResult = Left(strResult, n - 1)
                End If
            End If
            LastCredits = strResult
        End If
        Return result
    End Function

    ''' <summary>
    ''' Executes the HTTP GET of a given URL
    ''' </summary>
    ''' <param name="myURL">The URL to get (URL must be encoded!)</param>
    ''' <returns>The HTTP response that was received</returns>
    ''' <remarks></remarks>
    Private Shared Function ExecHttp(ByVal myURL As String) As String
        Dim myContent As String = ""
        Dim myEx As Exception = Nothing
        pMutex.WaitOne()    ' use a mutex in case a network timeout occurs and multiple request are done simultaneously
        Try
            Dim myRequest As System.Net.HttpWebRequest = CType(WebRequest.Create(myURL), HttpWebRequest)
            Dim myResponse As WebResponse = myRequest.GetResponse
            Dim myStream As IO.Stream = myResponse.GetResponseStream
            Dim myReader As New IO.StreamReader(myStream)
            myContent = myReader.ReadToEnd
            myReader.Close()
            myStream.Close()
            myResponse.Close()
        Catch ex As Exception
            myEx = ex
        End Try
        pMutex.ReleaseMutex()
        If Not myEx Is Nothing Then Throw myEx ' mutex has been release, so throw exception again
        Return myContent
    End Function

End Class
