Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting
Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics

<TestClass()> Public Class UpdateVersion5v5

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

    <TestMethod()> Public Sub TestForFragmentedMessageLoop()
        ' TODO: Add test logic here
        Dim TestKeyVal As String = "MsgLoopTest"
        Dim m As New xPLMessage
        Debug.Print("Preparing a message to fragment...")
        m.MsgType = xPLMessageTypeEnum.Trigger
        m.Target = "*"
        m.Schema = "log.basic"
        m.KeyValueList.Add("level", "inf")
        m.KeyValueList.Add(TESTKEY, TestKeyVal)
        m.KeyValueList.Add("text", New String("a"c, 1024))
        m.KeyValueList.Add("text2", New String("a"c, 1024)) ' second key 1024bytes will force fragmentation

        ' will send the generated fragmented message, 2 fragments
        Debug.Print("Sending it from xDev")
        xDev.Send(m)
        Debug.Print("Waiting for test message to be returned (reassembled)")
        If WaitForTestKey(yDev, TestKeyVal) Is Nothing Then     ' wait to make sure the message has been received by ydev
            Assert.Fail("Test message was not received")
        Else
            Debug.Print("Reassembled test message was received")
        End If

        ' create a request for a fragment of created message
        m = New xPLMessage
        m.MsgType = xPLMessageTypeEnum.Command
        m.Source = "tieske-test.somedevice"     ' just some sender, but not xdev or ydev
        m.Target = xDev.Address
        m.Schema = "fragment.request"
        m.KeyValueList.Add("command", "resend")
        m.KeyValueList.Add("message", "1")  ' the above fragmented message will have ID 1, so request a part from that one again
        m.KeyValueList.Add("part", "2")     ' request part 2 again
        ' clear receive queues and send the request for the fragment
        Debug.Print("Clearing receive queues and requesting a fragment again (source of request is some unknown device)...")
        xMessageList.Clear()
        yMessageList.Clear()
        Threading.Thread.Sleep(500)
        xPLListener.SendRawxPL(m.RawxPL)

        ' when the fragment is resend by xdev, ydev will also receive that fragment again and should not start
        ' requesting the missing fragments because it already has this message.
        ' the missing part are requested after 3 seconds, so set timeout to 5 seconds
        Debug.Print("Waiting for yDev to request the remaining parts again and completing the fragmented message for the second time...")
        m = WaitForTestKey(yDev, TestKeyVal, 5000)
        Assert.IsTrue(m Is Nothing, "The test message was received again, so an endless message loop was created")
        Debug.Print("SUCCESS: Message wasn't received a second time, so an endless message loop has been prevented.")

    End Sub

End Class
