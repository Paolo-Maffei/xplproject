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
    Private WithEvents xDev As New xPLDevice
    Private WithEvents yDev As New xPLDevice
    Private xMessageList As New Collection   ' messages received will be stored here, key is the msg value TestKey
    Private yMessageList As New Collection   ' messages received will be stored here, key is the msg value TestKey

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
        Dim x As Integer = 0
        xdev.Address = "tieske-libtest.xdev"
        ydev.Address = "tieske-libtest.ydev"
        xdev.Configurable = False
        ydev.Configurable = False
        xdev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        ydev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        xPLListener.ByPassHub = False

        xdev.Enable()
        yDev.Enable()
        Debug.Print("")
        Debug.Print("Test devices xDev (tieske-libtest.xdev) and yDev (tieske-libtest.ydev) enabled")
        ' wait for going online, max 5 seconds
        While (xdev.Status <> xPLDeviceStatus.Online Or ydev.Status <> xPLDeviceStatus.Online) And x < 50
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
                Debug.Print("xDev received message with testkey; " & v)
            End If
            If sender Is yDev Then
                yMessageList.Add(e.XplMsg, v)
            End If
        End If
    End Sub
    Private Function WaitForTestKey(ByVal sender As xPLDevice, ByVal TestKeyValue As String, Optional ByVal TimeOut As Integer = 5000) As xPLMessage
        Dim n As Integer = 0
        Dim Done As Boolean = False
        Dim result As xPLMessage = Nothing
        Debug.Print("Waiting for testkey; " & TestKeyValue)
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
            If Not Done Then Assert.IsTrue(n < TimeOut, "TestKey with value; '" & TestKeyValue & "' not received, timeing out...")
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
        Assert.IsTrue(v = msg.KeyValueList("test"), "The 1kb value sent, does not match the received value")
        Debug.Print("Success! The test message with 1kb value was received and the value matches the sent value.")
    End Sub

    <TestMethod()> Public Sub MessageSizeUnlimited()
        ' setup test message basics
        Dim msg As New xPLMessage
        Dim msgreturn As xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"
        xPLListener.ByPassHub = True

        ' TODO: Add test logic here
        Dim v As String = "test value here!"
        ' set test value to be 1kb length
        While v.Length < 1024
            v = v & v
        End While
        v = Left(v, 1024)
        Debug.Print("Creating message with 30 key-value pairs, sized 1kb each ...")
        Dim itemcount As Integer = 30
        For n As Integer = 1 To itemcount
            msg.KeyValueList.Add("test" & n.ToString, n.ToString & v)
        Next
        msg.KeyValueList.Add(TESTKEY, "MessageSizeTest")
        Debug.Print("Sending test message...")
        xDev.Send(msg)
        msgreturn = WaitForTestKey(yDev, "MessageSizeTest")
        For n As Integer = 1 To itemcount
            Assert.IsTrue(msg.KeyValueList("test" & n.ToString) = msgreturn.KeyValueList("test" & n.ToString), "The 1kb value sent, does not match the received value")
        Next
        Debug.Print("Success! The test message with 30 values, 1kb each was received and the values matched the sent values.")
    End Sub

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
        Debug.Print("Value returned: " & msg.KeyValueList("test"))
        Assert.IsTrue(v = msg.KeyValueList("test"), "The UTF8 value sent, does not match the received value")
        Debug.Print("Success! The value returned matches the value sent, so sending and receiving UTF8 works as expected.")
    End Sub

End Class
