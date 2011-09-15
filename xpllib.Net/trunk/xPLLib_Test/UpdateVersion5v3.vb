Option Strict On

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
        xPLTestInitialize()
    End Sub
    '
    ' Use TestCleanup to run code after each test has run
    <TestCleanup()> Public Sub MyTestCleanup()
        xPLTestCleanup()
    End Sub
#End Region

    <TestMethod()> Public Sub ValuesSizeUnlimited()
        ' setup test message basics
        Dim msg As New xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"

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


    '  The maximum message size limitation has returned in version 5.4, so this test is now obsolete
    ' 
    '<TestMethod()> Public Sub MessageSizeUnlimited()
    '    ' setup test message basics

    '    Dim requiredsize = 16 * 1024    ' 16kb minimum size required

    '    xPLListener.ByPassHub = True
    '    Debug.Print("Testing maximum message size while bypassing the hub")
    '    Debug.Print("====================================================")
    '    Dim withouthub As Integer = TestMaxMessageSize()
    '    Debug.Print("")
    '    Debug.Print("")

    '    ' cleanup and restart
    '    MyTestCleanup()
    '    MyTestInitialize()

    '    xPLListener.ByPassHub = False
    '    Debug.Print("Testing maximum message size while using the hub")
    '    Debug.Print("================================================")
    '    Dim withhub As Integer = TestMaxMessageSize()
    '    Debug.Print("")
    '    Debug.Print("")

    '    Assert.IsTrue(withouthub >= requiredsize, "Without using a hub supported size must be at least " & requiredsize & " bytes.")
    'End Sub

    'Private Function TestMaxMessageSize() As Integer
    '    ' setup test message basics
    '    Dim msg As New xPLMessage
    '    Dim msgreturn As xPLMessage
    '    msg.Target = "*"
    '    msg.MsgType = xPLMessageTypeEnum.Trigger
    '    msg.Schema = "xpllib.test"

    '    ' TODO: Add test logic here
    '    Dim v As String = "test value here!"
    '    ' set test value to be 1kb length
    '    While v.Length < 256
    '        v = v & v
    '    End While
    '    v = Left(v, 256 - 10)  ' reduce by 10, for key (8), = and lf
    '    Dim itemcount As Integer = 1
    '    Dim done As Boolean = False
    '    Dim size As Integer = 0
    '    Debug.Print("Starting messagesize test...")
    '    While Not done
    '        xMessageList.Clear()
    '        yMessageList.Clear()
    '        msg.KeyValueList.Clear()
    '        For n As Integer = 1 To itemcount
    '            msg.KeyValueList.Add("test" & Right("0000" & n.ToString, 4), v)
    '        Next
    '        msg.KeyValueList.Add(TESTKEY, "MessageSizeTest_" & Right("00000000" & size, 8))
    '        size = msg.RawxPL.Length
    '        msg.KeyValueList.Remove(msg.KeyValueList.IndexOf(TESTKEY))
    '        msg.KeyValueList.Add(TESTKEY, "MessageSizeTest_" & Right("00000000" & size, 8))
    '        'Debug.Print("Testing size: " & size)
    '        xDev.Send(msg)
    '        msgreturn = WaitForTestKey(yDev, "MessageSizeTest_" & Right("00000000" & size, 8))
    '        If msgreturn Is Nothing OrElse msgreturn.RawxPLReceived <> msg.RawxPL Then
    '            ' failure
    '            Debug.Print("Initial 256byte block size test failed at " & msg.RawxPL.Length & " bytes. Reason; " & CStr(IIf(msgreturn Is Nothing, "timeout.", "raw xpl string didn't match.")))
    '            done = True
    '        Else
    '            ' matches
    '            itemcount = itemcount + 1   ' increase size
    '        End If
    '    End While
    '    ' continue with 1 byte increases
    '    done = False
    '    msg.KeyValueList.Remove(0)  ' remove 1 key to reverse last failure
    '    Dim key As xPLKeyValuePair = msg.KeyValueList(0)  ' key to modify with extra chars while testing
    '    While Not done
    '        xMessageList.Clear()
    '        yMessageList.Clear()
    '        size = msg.RawxPL.Length
    '        msg.KeyValueList(msg.KeyValueList.IndexOf(TESTKEY)).Value = "MessageSizeTest_" & Right("00000000" & size, 8)
    '        'Debug.Print("Testing size: " & size)
    '        xDev.Send(msg)
    '        msgreturn = WaitForTestKey(yDev, "MessageSizeTest_" & Right("00000000" & size, 8))
    '        If msgreturn Is Nothing OrElse msgreturn.RawxPLReceived <> msg.RawxPL Then
    '            ' failure
    '            Debug.Print("Final size test failed at " & msg.RawxPL.Length & " bytes. Reason; " & CStr(IIf(msgreturn Is Nothing, "timeout.", "raw xpl string didn't match.")))
    '            'Debug.Print(msg.RawxPL)
    '            done = True
    '        Else
    '            ' matches
    '            key.Value = key.Value & "x"  ' increase size
    '        End If
    '    End While
    '    Debug.Print("Maximum messagesize supported; " & size - 1 & " bytes.")
    '    Return (size - 1)
    'End Function

    <TestMethod()> Public Sub ValuesUTF8allowed()
        ' test both sending and parsing
        ' setup test message basics
        Dim msg As New xPLMessage
        msg.Target = "*"
        msg.MsgType = xPLMessageTypeEnum.Trigger
        msg.Schema = "xpllib.test"

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
