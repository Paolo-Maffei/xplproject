Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting
Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics

<TestClass()> Public Class UpdateVersion5v3

    Private testContextInstance As TestContext

    '''<summary>
    '''Gets or sets the test context which provides
    '''information about and functionality for the current test run.
    '''</summary>
    Public Property TestContext() As TestContext
        Get
            Return testContextInstance
        End Get
        Set(ByVal value As TestContext)
            testContextInstance = Value
        End Set
    End Property

#Region "Additional test attributes"

    Private Const TESTKEY As String = "testkey"
    Private WithEvents xDev As xPLDevice
    Private WithEvents yDev As xPLDevice
    Private xMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey
    Private yMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey

    '
    ' You can use the following additional attributes as you write your tests:
    '
    ' Use ClassInitialize to run code before running the first test in the class
    ' <ClassInitialize()> Public Shared Sub MyClassInitialize(ByVal testContext As TestContext)
    ' End Sub
    '
    ' Use ClassCleanup to run code after all tests in a class have run
    ' <ClassCleanup()> Public Shared Sub MyClassCleanup()
    ' End Sub
    '
    ' Use TestInitialize to run code before running each test
    <TestInitialize()> Public Sub MyTestInitialize()
        xDev = New xPLDevice
        yDev = New xPLDevice
        xMessageList = New Collection
        yMessageList = New Collection

        Dim x As Integer = 0
        xDev.Address = "tieske-libtest.xdev"
        yDev.Address = "tieske-libtest.ydev"
        xDev.Configurable = False
        yDev.Configurable = False
        xDev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        yDev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        xPLListener.ByPassHub = False

        xDev.Enable()
        yDev.Enable()
        Debug.Print("")
        Debug.Print("Test devices xDev (tieske-libtest.xdev) and yDev (tieske-libtest.ydev) enabled")
        ' wait for going online, max 5 seconds
        While (xDev.Status <> xPLDeviceStatus.Online Or yDev.Status <> xPLDeviceStatus.Online) And x < 50
            Threading.Thread.Sleep(100)
            x = x + 1
        End While
        Assert.IsTrue(x < 50, "Devices not online within 5 seconds, test aborted")
        Debug.Print("Both online, commencing test")
        Debug.Print("")
    End Sub

    '
    ' Use TestCleanup to run code after each test has run
    <TestCleanup()> Public Sub MyTestCleanup()
        Debug.Print("")
        Debug.Print("Test finished, now destroying xDev and yDev devices.")
        If Not xDev Is Nothing Then
            xDev.Dispose()
            xDev = Nothing
        End If
        If Not xMessageList Is Nothing Then
            xMessageList.Clear()
            xMessageList = Nothing
        End If
        If Not yDev Is Nothing Then
            yDev.Dispose()
            yDev = Nothing
        End If
        If Not yMessageList Is Nothing Then
            yMessageList.Clear()
            yMessageList = Nothing
        End If
        Debug.Print("Done.")
    End Sub
    ' End Sub
    '
    Private Sub xMessageReceived(ByVal sender As xPLDevice, ByVal e As xPLDevice.xPLEventArgs) Handles xDev.xPLMessageReceived
        MessageReceived(sender, e)
    End Sub
    Private Sub yMessageReceived(ByVal sender As xPLDevice, ByVal e As xPLDevice.xPLEventArgs) Handles yDev.xPLMessageReceived
        MessageReceived(sender, e)
    End Sub
    Private Sub MessageReceived(ByVal sender As xPLDevice, ByVal e As xPLDevice.xPLEventArgs)
        If e.XplMsg.KeyValueList.IndexOf(TESTKEY) <> -1 Then
            Dim v As String = e.XplMsg.KeyValueList(TESTKEY)
            If sender Is xDev Then
                xMessageList.Add(e.XplMsg, v)
            End If
            If sender Is yDev Then
                yMessageList.Add(e.XplMsg, v)
            End If
        End If
    End Sub
    ''' <summary>
    ''' Wait for a message to arrive with a specific testkey, returns the message, or Nothing if it timesout
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="TestKeyValue"></param>
    ''' <param name="TimeOut">Timeout in milliseconds</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function WaitForTestKey(ByVal sender As xPLDevice, ByVal TestKeyValue As String, Optional ByVal TimeOut As Integer = 5000) As xPLMessage
        Dim n As Integer = 0
        Dim Done As Boolean = False
        Dim result As xPLMessage = Nothing
        While Not Done
            Threading.Thread.Sleep(100)
            n = n + 100
            If sender Is xDev Then
                Done = xMessageList.Contains(TestKeyValue)
                If Done Then result = CType(xMessageList(TestKeyValue), xPLMessage)
            End If
            If sender Is yDev Then
                Done = yMessageList.Contains(TestKeyValue)
                If Done Then result = CType(yMessageList(TestKeyValue), xPLMessage)
            End If
            If Not Done And n > TimeOut Then
                Done = True ' timeout, 'Nothing is returned
            End If
        End While
        Return result
    End Function
#End Region

    <TestMethod()> Public Sub ValuesSizeUnlimited()
        ' setup test message basics
        Dim msg As New xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"

        ' TODO: Add test logic here
        Dim v As String = "test value here!"
        ' set test value to be 1kb length
        While v.Length < 1024
            v = v & v
        End While
        v = Left(v, 1024)
        Debug.Print("Creating message with key-value pair, test value sized 1kb ...")
        msg.KeyValueList.Add("test", v)
        msg.KeyValueList.Add(TESTKEY, "1kb-value")
        Debug.Print("Sending test message...")
        xDev.Send(msg)
        msg = WaitForTestKey(yDev, "1kb-value")
        Assert.IsTrue(msg IsNot Nothing, "The 1kb value sent, was not returned, timedout while waiting for the message.")
        Assert.IsTrue(v = msg.KeyValueList("test"), "The 1kb value sent, does not match the received value")
        Debug.Print("Success! The test message with 1kb value was received and the value matches the sent value.")
    End Sub

    <TestMethod()> Public Sub MessageSizeUnlimited()
        ' setup test message basics

        Dim requiredsize = 16 * 1024    ' 16kb minimum size required

        xPLListener.ByPassHub = True
        Debug.Print("Testing maximum message size while bypassing the hub")
        Debug.Print("====================================================")
        Dim withouthub As Integer = TestMaxMessageSize()
        Debug.Print("")
        Debug.Print("")

        ' cleanup and restart
        MyTestCleanup()
        MyTestInitialize()

        xPLListener.ByPassHub = False
        Debug.Print("Testing maximum message size while using the hub")
        Debug.Print("================================================")
        Dim withhub As Integer = TestMaxMessageSize()
        Debug.Print("")
        Debug.Print("")

        Assert.IsTrue(withouthub >= requiredsize, "Without using a hub supported size must be at least " & requiredsize & " bytes.")
    End Sub

    Private Function TestMaxMessageSize() As Integer
        ' setup test message basics
        Dim msg As New xPLMessage
        Dim msgreturn As xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"

        ' TODO: Add test logic here
        Dim v As String = "test value here!"
        ' set test value to be 1kb length
        While v.Length < 256
            v = v & v
        End While
        v = Left(v, 256 - 10)  ' reduce by 10, for key (8), = and lf
        Dim itemcount As Integer = 1
        Dim done As Boolean = False
        Dim size As Integer = 0
        Debug.Print("Starting messagesize test...")
        While Not done
            xMessageList.Clear()
            yMessageList.Clear()
            msg.KeyValueList.Clear()
            For n As Integer = 1 To itemcount
                msg.KeyValueList.Add("test" & Right("0000" & n.ToString, 4), v)
            Next
            msg.KeyValueList.Add(TESTKEY, "MessageSizeTest_" & Right("00000000" & size, 8))
            size = msg.RawxPL.Length
            msg.KeyValueList.Remove(msg.KeyValueList.IndexOf(TESTKEY))
            msg.KeyValueList.Add(TESTKEY, "MessageSizeTest_" & Right("00000000" & size, 8))
            'Debug.Print("Testing size: " & size)
            xDev.Send(msg)
            msgreturn = WaitForTestKey(yDev, "MessageSizeTest_" & Right("00000000" & size, 8))
            If msgreturn Is Nothing OrElse msgreturn.RawxPLReceived <> msg.RawxPL Then
                ' failure
                Debug.Print("Initial 256byte block size test failed at " & msg.RawxPL.Length & " bytes. Reason; " & CStr(IIf(msgreturn Is Nothing, "timeout.", "raw xpl string didn't match.")))
                done = True
            Else
                ' matches
                itemcount = itemcount + 1   ' increase size
            End If
        End While
        ' continue with 1 byte increases
        done = False
        msg.KeyValueList.Remove(0)  ' remove 1 key to reverse last failure
        Dim key As xPLKeyValuePair = msg.KeyValueList(0)  ' key to modify with extra chars while testing
        While Not done
            xMessageList.Clear()
            yMessageList.Clear()
            size = msg.RawxPL.Length
            msg.KeyValueList(msg.KeyValueList.IndexOf(TESTKEY)).Value = "MessageSizeTest_" & Right("00000000" & size, 8)
            'Debug.Print("Testing size: " & size)
            xDev.Send(msg)
            msgreturn = WaitForTestKey(yDev, "MessageSizeTest_" & Right("00000000" & size, 8))
            If msgreturn Is Nothing OrElse msgreturn.RawxPLReceived <> msg.RawxPL Then
                ' failure
                Debug.Print("Final size test failed at " & msg.RawxPL.Length & " bytes. Reason; " & CStr(IIf(msgreturn Is Nothing, "timeout.", "raw xpl string didn't match.")))
                'Debug.Print(msg.RawxPL)
                done = True
            Else
                ' matches
                key.Value = key.Value & "x"  ' increase size
            End If
        End While
        Debug.Print("Maximum messagesize supported; " & size - 1 & " bytes.")
        Return (size - 1)
    End Function

    <TestMethod()> Public Sub ValuesUTF8allowed()
        ' TODO: Add test logic here
        ' test both sending and parsing
        ' setup test message basics
        Dim msg As New xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"

        ' TODO: Add test logic here
        Dim v As String = "ãéêçúöë"    ' some general non-ASCII characters
        Assert.IsTrue(v.Length <> Encoding.UTF8.GetBytes(v).Length, "Expected more bytes than characters due to UTF8 characters.")
        Debug.Print("Testing value: " & v)
        Debug.Print("Test value has " & v.Length & " characters, and consists of " & Encoding.UTF8.GetBytes(v).Length & " bytes.")
        msg.KeyValueList.Add("test", v)
        msg.KeyValueList.Add(TESTKEY, "utf8test")
        Debug.Print("Sending test message...")
        xDev.Send(msg)
        msg = WaitForTestKey(yDev, "utf8test")
        Assert.IsTrue(msg IsNot Nothing, "The message containing UTF* characters was not returned, timedout while waiting for the message.")
        Debug.Print("Value returned: " & msg.KeyValueList("test"))
        Assert.IsTrue(v = msg.KeyValueList("test"), "The UTF8 value sent, does not match the received value")
        Debug.Print("Success! The value returned matches the value sent, so sending and receiving UTF8 works as expected.")
    End Sub

End Class
