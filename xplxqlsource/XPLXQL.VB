Imports System.ServiceProcess
'**************************************
'* xPL XQL
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
'*
'* This program is free software; you can redistribute it and/or
'* modify it under the terms of the GNU General Public License
'* as published by the Free Software Foundation; either version 2
'* of the License, or (at your option) any later version.
'*
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
'**************************************

Public Class Service1
    Inherits System.ServiceProcess.ServiceBase

#Region " Component Designer generated code "

    Public Sub New()
        MyBase.New()

        ' This call is required by the Component Designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call

    End Sub

    'UserService overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    ' The main entry point for the process
    <MTAThread()> _
    Shared Sub Main()
        Dim ServicesToRun() As System.ServiceProcess.ServiceBase

        ' More than one NT Service may run within the same process. To add
        ' another service to this process, change the following line to
        ' create a second service object. For example,
        '
        '   ServicesToRun = New System.ServiceProcess.ServiceBase () {New Service1, New MySecondUserService}
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase () {New Service1}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        components = New System.ComponentModel.Container()
        Me.ServiceName = "Service1"
    End Sub

#End Region

    Public xPLXQLData As String
    Public XQLConnect As String

    ' queries
    Public sqls_select(255) As ADODB.Recordset
    Public sqls_status(255) As Integer
    Public sqls_Timeout(255) As Date

    ' database
    Public dbs As New ADODB.Connection()

    Protected Overrides Sub OnStart(ByVal args() As String)

        ' system paths
        xPLXQLData = System.Reflection.Assembly.GetExecutingAssembly.Location
        xPLXQLData = xPLXQLData.Substring(0, InStrRev(xPLXQLData, "\"))

        ' load parameters
        Dim xml As New XmlTextReader(xPLXQLData + "xplxql.xml")
        While xml.Read()
            Select Case xml.NodeType
                Case XmlNodeType.Element
                    Select Case xml.Name
                        Case "datasource"
                            XQLConnect = xml.GetAttribute("connect")
                    End Select
            End Select
        End While
        xml.Close()

        ' open db connection
        Try
            dbs.ConnectionString = XQLConnect
            dbs.Open()
        Catch ex As Exception
            Call WriteErrorLog("XQL DB Connect Failed (" + Err.Description + ")")
        End Try

        ' init listener
        Call InitListener()

    End Sub

    Protected Overrides Sub OnStop()

        ' close
        Try
            dbs.Close()
        Catch ex As Exception
        End Try

    End Sub

    Private WithEvents xPLListen As xpllib.XplListener

    Private Sub InitListener()
        Try
            xPLListen = New xpllib.XplListener("tonyt-xql", 1)
            '     xPLListen.Filters.Add(New xpllib.XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "XQL", "*"))
            xPLListen.XplOnTimer = AddressOf xPLListen_OnTimer
            xPLListen.Listen()
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("xPL Initialisation failed: " & ex.ToString())
            End If
        End Try
    End Sub

    Private Sub xPLListen_OnTimer()

        Dim x As Integer

        ' clear timed out sqls
        For x = 51 To 255
            If sqls_status(x) = -1 And sqls_Timeout(x) < Now() Then
                sqls_status(x) = 0
                On Error Resume Next
                sqls_select(x).Close()
                On Error GoTo 0
            End If
        Next x

    End Sub

    Private Sub xPLListen_xPLMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles xPLListen.XplMessageReceived

        Dim strMsg As String
        Dim strCommand As String
        Dim SQLID As Integer
        Dim strSQL As String
        Dim IsOneShot As Boolean
        Dim strTag As String

        strMsg = ""
        strCommand = e.XplMsg.GetParam(1, "command").ToUpper.Trim
        SQLID = Val(e.XplMsg.GetParam(1, "sqlid"))
        strSQL = e.XplMsg.GetParam(1, "sql").Trim
        IsOneShot = False
        If strSQL <> "" And SQLID = 0 Then IsOneShot = True
        If SQLID >= 0 And SQLID <= 256 Then
            Select Case strCommand
                Case "LOOKUP"
                    If strSQL <> "" Then strMsg = LookupSQL(strSQL)
                Case "OPEN"
                    If strSQL <> "" Then strMsg = OpenSQL(strSQL, SQLID)
                Case "CLOSE"
                    If SQLID <> 0 Then Call CloseSQL(SQLID)
                Case "COUNT"
                    If SQLID > 50 Then strMsg = CountSQL(SQLID)
                Case "MOVE"
                    If SQLID > 50 Then strMsg = MoveSQL(SQLID, e.XplMsg.GetParam(1, "how").ToUpper.Trim)
                Case "ADD"
                    If IsOneShot Then SQLID = OneShotSQL(strSQL)
                    If SQLID <> 0 Then strMsg = AddSQL(SQLID, e.XplMsg)
                    If IsOneShot And SQLID <> 0 Then Call CloseSQL(SQLID)
                Case "EDIT"
                    If IsOneShot Then SQLID = OneShotSQL(strSQL)
                    If SQLID <> 0 Then strMsg = EditSQL(SQLID, e.XplMsg)
                    If IsOneShot And SQLID <> 0 Then Call CloseSQL(SQLID)
                Case "FIND"
                    If IsOneShot Then SQLID = OneShotSQL(strSQL)
                    If SQLID > 50 Then strMsg = FindSQL(SQLID, e.XplMsg.GetParam(1, "how").ToUpper.Trim, e.XplMsg.GetParam(1, "where"))
                    If IsOneShot And SQLID <> 0 Then Call CloseSQL(SQLID)
                Case "DELETE"
                    If SQLID > 50 Then strMsg = DeleteSQL(SQLID)
            End Select
        End If

        ' generate response
        If strMsg <> "" Then
            ' send response
            strTag = e.XplMsg.GetParam(1, "tag")
            If strTag <> "" Then strMsg = strMsg + "TAG=" & strTag & Chr(10)
            Call xPLListen.SendMessage("xpl-stat", e.XplMsg.GetParam(0, "source"), e.XplMsg.XPL_Msg(1).Section, strMsg)
        End If

    End Sub

    Function OneShotSQL(ByVal strSQL As String) As Integer

        Dim x As Integer
        Dim y As Integer
        Dim r(1) As Integer

        ' open a new sql query
        r(0) = 51
        r(1) = 255
        For x = r(0) To r(1)
            If sqls_status(x) = 0 Then
                sqls_Timeout(x) = DateAdd("n", 10, Now())
                sqls_status(x) = -1
                On Error GoTo opensqlfailed
                sqls_select(x) = New ADODB.Recordset()
                sqls_select(x).Open(strSQL, dbs, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)
                On Error GoTo 0
                OneShotSQL = x
                Exit Function
            End If
        Next x

opensqlfailed:
        On Error GoTo 0
        If x < 256 Then sqls_status(x) = 0
        If x < 51 Then Exit Function
        OneShotSQL = 0

    End Function

    ' function to run a query
    Function LookupSQL(ByVal strSQL As String) As String

        Dim x As Integer
        Dim rst As New ADODB.Recordset()

        ' lookup data
        On Error GoTo lookupfailed
        rst.Open(strSQL, dbs, ADODB.CursorTypeEnum.adOpenKeyset)
        On Error GoTo 0
        If rst.EOF Then GoTo lookupfailed
        LookupSQL = "STATUS=OK" + Chr(10)
        LookupSQL = LookupSQL + "COMMAND=LOOKUP" + Chr(10)
        If rst.EOF Then GoTo lookupfailed
        For x = 0 To rst.Fields.Count - 1
            LookupSQL = LookupSQL + UCase(rst.Fields(x).Name) + "=" & rst.Fields(x).Value & Chr(10)
        Next x
        rst.Close()
        Exit Function

lookupfailed:
        On Error GoTo 0
        LookupSQL = "STATUS=FAIL" + Chr(10)
        LookupSQL = LookupSQL + "COMMAND=LOOKUP" + Chr(10)

    End Function

    ' function to run a query
    Function OpenSQL(ByVal strSQL As String, ByVal SQLID As Integer) As String

        Dim x As Integer
        Dim y As Integer
        Dim r(1) As Integer

        ' open a new sql query
        r(0) = 51
        r(1) = 255
        If SQLID <> 0 Then
            r(0) = SQLID
            r(1) = SQLID
            If sqls_status(SQLID) = -1 Then
                ' close before opening
                sqls_status(SQLID) = 0
                On Error Resume Next
                sqls_select(SQLID).Cancel()
                sqls_select(SQLID).Close()
                On Error GoTo 0
            End If
        End If
        For x = r(0) To r(1)
            If sqls_status(x) = 0 Then
                sqls_Timeout(x) = DateAdd("n", 10, Now())
                sqls_status(x) = -1
                On Error GoTo opensqlfailed
                sqls_select(x) = New ADODB.Recordset()
                sqls_select(x).Open(strSQL, dbs, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)
                On Error GoTo 0
                If x > 50 Then
                    ' return record
                    OpenSQL = "STATUS=OK" + Chr(10)
                    OpenSQL = OpenSQL + "COMMAND=OPEN" + Chr(10)
                    OpenSQL = OpenSQL + "SQLID=" + Mid$(Str$(x), 2) + Chr(10)
                    If Not sqls_select(x).EOF Then
                        For y = 0 To sqls_select(x).Fields.Count - 1
                            OpenSQL = OpenSQL + Left$(UCase(sqls_select(x).Fields(y).Name), 16) + "=" & sqls_select(x).Fields(y).Value & Chr(10)
                        Next y
                    End If
                End If
                Exit Function
            End If
        Next x

opensqlfailed:
        On Error GoTo 0
        If x < 256 Then sqls_status(x) = 0
        If x < 51 Then Exit Function
        OpenSQL = "STATUS=FAIL" + Chr(10)
        OpenSQL = OpenSQL + "COMMAND=OPEN" + Chr(10)

    End Function

    ' sub to close a query
    Sub CloseSQL(ByVal SQLID As Integer)

        ' close
        If sqls_status(SQLID) = 0 Then Exit Sub
        On Error Resume Next
        If SQLID < 51 Then sqls_select(SQLID).Update() ' force save before close
        sqls_select(SQLID).Close()
        sqls_status(SQLID) = 0
        On Error GoTo 0

    End Sub

    ' fucntion to return record count
    Function CountSQL(ByVal SQLID As Integer) As String

        Dim x As Long

        ' return count
        If sqls_status(SQLID) = 0 Then GoTo countsqlfailed
        On Error GoTo countsqlfailed
        sqls_select(SQLID).MoveLast()
        x = sqls_select(SQLID).RecordCount
        sqls_select(SQLID).MoveFirst()
        On Error GoTo 0
        CountSQL = "STATUS=OK" + Chr(10)
        CountSQL = CountSQL + "COMMAND=COUNT" + Chr(10)
        CountSQL = CountSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        CountSQL = CountSQL + "RECORDS=" + Mid$(Str$(x), 2) + Chr(10)
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

countsqlfailed:
        On Error GoTo 0
        CountSQL = "STATUS=FAIL" + Chr(10)
        CountSQL = CountSQL + "COMMAND=COUNT" + Chr(10)
        CountSQL = CountSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' sub to move record
    Function MoveSQL(ByVal SQLID As Integer, ByVal How As String) As String

        Dim y As Integer

        ' action move
        If sqls_status(SQLID) = 0 Then GoTo movefailed
        Select Case How
            Case "FIRST"
                On Error GoTo movefailed
                sqls_select(SQLID).MoveFirst()
                On Error GoTo 0
            Case "LAST"
                On Error GoTo movefailed
                sqls_select(SQLID).MoveLast()
                On Error GoTo 0
            Case "PREVIOUS"
                On Error GoTo movefailed
                sqls_select(SQLID).MovePrevious()
                On Error GoTo 0
            Case "NEXT"
                On Error GoTo movefailed
                sqls_select(SQLID).MoveNext()
                On Error GoTo 0
        End Select
        MoveSQL = "STATUS=OK" + Chr(10)
        MoveSQL = MoveSQL + "COMMAND=MOVE-" + How + Chr(10)
        MoveSQL = MoveSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        If sqls_select(SQLID).EOF Or sqls_select(SQLID).BOF Then GoTo movefailed
        For y = 0 To sqls_select(SQLID).Fields.Count - 1
            MoveSQL = MoveSQL + Left$(UCase(sqls_select(SQLID).Fields(y).Name), 16) + "=" & sqls_select(SQLID).Fields(y).Value & Chr(10)
        Next y
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

movefailed:
        On Error GoTo 0
        MoveSQL = "STATUS=FAIL" + Chr(10)
        MoveSQL = MoveSQL + "COMMAND=MOVE-" + How + Chr(10)
        MoveSQL = MoveSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' function to add record
    Function AddSQL(ByVal SQLID As Integer, ByVal e As xpllib.XplMsg) As String

        Dim x As Integer

        ' add record
        If sqls_status(SQLID) = 0 Then GoTo addnewfailed
        On Error GoTo addnewfailed
        sqls_select(SQLID).AddNew()
        For x = 0 To sqls_select(SQLID).Fields.Count - 1
            If xPL_ChkParam(True, sqls_select(SQLID).Fields(x).Name, e) = True Then
                sqls_select(SQLID).Fields(x).Value = e.GetParam(1, sqls_select(SQLID).Fields(x).Name)
            End If
        Next x
        sqls_select(SQLID).Update()
        On Error GoTo 0
        If SQLID < 51 Then Exit Function
        AddSQL = "STATUS=OK" + Chr(10)
        AddSQL = AddSQL + "COMMAND=ADD" + Chr(10)
        AddSQL = AddSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

addnewfailed:
        On Error GoTo 0
        If SQLID < 51 Then Exit Function
        AddSQL = "STATUS=FAIL" + Chr(10)
        AddSQL = AddSQL + "COMMAND=ADD" + Chr(10)
        AddSQL = AddSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' function to edit record
    Function EditSQL(ByVal SQLID As Integer, ByVal e As xpllib.XplMsg) As String

        Dim x As Integer
        Dim newval As Integer

        ' edit record
        If sqls_status(SQLID) = 0 Then GoTo editfailed
        If sqls_select(SQLID).EOF Then GoTo editfailed
        On Error GoTo editfailed
        For x = 0 To sqls_select(SQLID).Fields.Count - 1
            If xPL_ChkParam(True, sqls_select(SQLID).Fields(x).Name, e) = True Then
                sqls_select(SQLID).Fields(x).Value = e.GetParam(1, sqls_select(SQLID).Fields(x).Name)
            End If
        Next x
        sqls_select(SQLID).Update()
        On Error GoTo 0
        If SQLID < 51 Then Exit Function
        EditSQL = "STATUS=OK" + Chr(10)
        EditSQL = EditSQL + "COMMAND=EDIT" + Chr(10)
        EditSQL = EditSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

editfailed:
        On Error GoTo 0
        If SQLID < 51 Then Exit Function
        EditSQL = "STATUS=FAIL" + Chr(10)
        EditSQL = EditSQL + "COMMAND=EDIT" + Chr(10)
        EditSQL = EditSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' function to find a record
    Function FindSQL(ByVal SQLID As Integer, ByVal How As String, ByVal Where As String) As String

        Dim y As Integer

        ' find record
        If sqls_status(SQLID) = 0 Then GoTo findfailed
        On Error GoTo findfailed
        Select Case UCase(How)
            Case "FIRST"
                sqls_select(SQLID).MoveFirst()
                sqls_select(SQLID).Find(Where, , ADODB.SearchDirectionEnum.adSearchForward)
            Case "LAST"
                sqls_select(SQLID).MoveLast()
                sqls_select(SQLID).Find(Where, , ADODB.SearchDirectionEnum.adSearchBackward)
            Case "NEXT"
                sqls_select(SQLID).MoveNext()
                sqls_select(SQLID).Find(Where, , ADODB.SearchDirectionEnum.adSearchForward)
            Case "PREVIOUS"
                sqls_select(SQLID).MovePrevious()
                sqls_select(SQLID).Find(Where, , ADODB.SearchDirectionEnum.adSearchBackward)
        End Select
        On Error GoTo 0
        FindSQL = "STATUS=OK" + Chr(10)
        FindSQL = FindSQL + "COMMAND=FIND-" + How + Chr(10)
        FindSQL = FindSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        If sqls_select(SQLID).EOF Or sqls_select(SQLID).BOF Then GoTo findfailed
        For y = 0 To sqls_select(SQLID).Fields.Count - 1
            FindSQL = FindSQL + Left$(UCase(sqls_select(SQLID).Fields(y).Name), 16) + "=" & sqls_select(SQLID).Fields(y).Value & Chr(10)
        Next y
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

findfailed:
        On Error GoTo 0
        FindSQL = "STATUS=FAIL" + Chr(10)
        FindSQL = FindSQL + "COMMAND=FIND-" + How + Chr(10)
        FindSQL = FindSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' function to delete a record
    Function DeleteSQL(ByVal SQLID As Integer) As String

        ' delete record
        If sqls_status(SQLID) = 0 Then GoTo deletefailed
        On Error GoTo deletefailed
        sqls_select(SQLID).Delete()
        On Error GoTo 0
        DeleteSQL = "STATUS=OK" + Chr(10)
        DeleteSQL = DeleteSQL + "COMMAND=DELETE" + Chr(10)
        DeleteSQL = DeleteSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)
        sqls_Timeout(SQLID) = DateAdd("n", 10, Now())
        Exit Function

deletefailed:
        On Error GoTo 0
        DeleteSQL = "STATUS=FAIL" + Chr(10)
        DeleteSQL = DeleteSQL + "COMMAND=DELETE" + Chr(10)
        DeleteSQL = DeleteSQL + "SQLID=" + Mid$(Str$(SQLID), 2) + Chr(10)

    End Function

    ' routine to check a parameter exists
    Public Function xPL_ChkParam(ByVal inBody As Boolean, ByVal strName As String, ByVal e As xpllib.XplMsg) As Boolean

        Dim y As Integer
        Dim x As Integer

        ' check
        y = 0
        If inBody = True Then y = 1
        For x = 0 To e.XPL_Msg(1).DC
            If UCase(e.XPL_Msg(y).Details(x).keyName) Like UCase(strName) Then
                ' got match
                xPL_ChkParam = True
                Exit Function
            End If
        Next x
        xPL_ChkParam = False

    End Function

    ' routine to write error log
    Public Sub WriteErrorLog(ByVal ErrMsg As String)
        Dim f As Integer
        f = FreeFile()
        FileOpen(f, xPLXQLData + "\error_log.txt", OpenMode.Append, OpenAccess.Write, OpenShare.Default)
        PrintLine(f, Format(Now, "ddd dd/MM/yy HH:mm:ss") + " : " + ErrMsg)
        FileClose(f)
    End Sub

End Class
