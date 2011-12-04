Imports Microsoft.VisualStudio.TestTools.UnitTesting

Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics


'''<summary>
'''This is a test class for xPLFragmentedMsgTest and is intended
'''to contain all xPLFragmentedMsgTest Unit Tests
'''</summary>
<TestClass()> _
Public Class xPLFragmentedMsgTest


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

    '''<summary>
    '''A test for xPLFragmentedMsg Constructor
    '''</summary>
    <TestMethod()> _
    Public Sub xPLFragmentedMsgConstructorTest()
        Dim msg As New xPLMessage
        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = yDev.Address

        ' first test a message to be sent
        Debug.Print("1/2 Testing a message to be sent...")
        msg.KeyValueList.Add("somekey", "some value")
        For n = 0 To 9
            msg.KeyValueList.Add("testkey" & n.ToString, New String("A"c, 1000))
        Next
        msg.Source = xDev.Address
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, xDev)
        Dim actual As String
        actual = target.Source
        Assert.IsTrue(xDev.Address = actual, "Fragmented source (" & actual & ") should have been equal to xdev.address (" & xDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Created, "Fragmented message should have been created as a 'Created' message (to be sent).")
        Debug.Print("Success: 'Created' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = xDev.Address & ":1", "MessageID = '" & target.MessageID & "', while '" & xDev.Address & ":1" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 10, "Count = " & target.Count.ToString & ", while 10 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")
        For n As Integer = 1 To target.Count
            Assert.IsTrue(target.Fragment(n).KeyValueList.IndexOf("partid") = 0, "Expected the key 'partid' as the first key in fragment " & n.ToString & ".")
            Dim partid As String = target.Fragment(n).KeyValueList("partid")
            Assert.IsTrue(partid = n.ToString & "/" & target.Count & Mid(partid, partid.IndexOf(":") + 1), "Incorrect partid found in fragment " & n.ToString & ".")
            Debug.Print("Success: partid '" & partid & "' is the first key of fragment " & n.ToString & ", and seems ok.")
            If n = 1 Then
                Assert.IsTrue(target.Fragment(n).KeyValueList.IndexOf("schema") = 1, "Expected the key 'schema' as the second key in fragment " & n.ToString & ".")
                Assert.IsTrue(target.Fragment(n).KeyValueList("schema") = msg.Schema, "Schema in fragment 1, key 2, should have been '" & msg.Schema & "' instead of '" & target.Fragment(n).KeyValueList("schema") & "'.")
                Debug.Print("Success: fragment 1 contains the proper schema as key 2")
            End If
        Next
        Debug.Print("")

        ' second test a message received
        Debug.Print("2/2 Testing a message received...")
        msg.Source = yDev.Address
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("schema", msg.Schema)
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Add("partid", "1/7:34")
        msg.KeyValueList.Add("somekey", "some value")

        target = New xPLFragmentedMsg(msg, xDev)
        actual = target.Source
        Assert.IsTrue(yDev.Address = actual, "Fragmented source (" & actual & ") should have been equal to ydev.address (" & yDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Received, "Fragmented message should have been created as a 'Received' message.")
        Debug.Print("Success: 'Received' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = msg.Source & ":34", "MessageID = '" & target.MessageID & "', while '" & msg.Source & ":34" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 7, "Count = " & target.Count.ToString & ", while 7 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")

        ' test some error scenarios
        TestConstructorNoKVpairs()
    End Sub
    Private Sub TestConstructorNoKVpairs()
        ' - no KV pairs in original message, both creating and receiving

        Dim msg As New xPLMessage
        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = yDev.Address

        ' first test a message to be sent
        Debug.Print("")
        Debug.Print("TESTING CASE WITH NO KEY-VALUE PAIRS IN MESSAGE")
        Debug.Print("")
        Debug.Print("1/2 Testing a message to be sent...")
        'msg.KeyValueList.Add("somekey", "some value")
        'For n = 0 To 9
        '    msg.KeyValueList.Add("testkey" & n.ToString, New String("A"c, 1000))
        'Next
        msg.Source = xDev.Address
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, xDev)
        Assert.IsTrue(xDev.Address = target.Source, "Fragmented source (" & target.Source & ") should have been equal to xdev.address (" & xDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Created, "Fragmented message should have been created as a 'Created' message (to be sent).")
        Debug.Print("Success: 'Created' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = xDev.Address & ":2", "MessageID = '" & target.MessageID & "', while '" & xDev.Address & ":2" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 1, "Count = " & target.Count.ToString & ", while 1 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")
        Assert.IsTrue(target.Fragment(1).KeyValueList.IndexOf("partid") = 0, "Expected partid key as first key value pair")
        Assert.IsTrue(target.Fragment(1).KeyValueList.IndexOf("schema") = 1, "Expected schema key as second key value pair")
        Assert.IsTrue(target.Fragment(1).KeyValueList.Count = 2, "Expected only 2 keys in fragment 1")
        Debug.Print("Success: single fragment, with only the 2 fragment overhead keys in the correct order detected.")
        Debug.Print("")

        ' second test a message received
        Debug.Print("2/2 Testing a message received...")
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", msg.Schema) '"justsome.schema")

        Debug.Print("Created first fragment, now creating a new fragmented message...")
        target = New xPLFragmentedMsg(msg, xDev) ' create message from 1st fragment
        Debug.Print("Adding same fragment again to newly created fragmented message...")
        target.AddFragment(msg) ' Add same fragment again

        msg = New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "2/2:35")

        Dim msg2 As xPLMessage = target.AddFragment(msg)       ' add second fragment, now complete, so result should be returned

        Assert.IsTrue(msg.Source = msg2.Source, "Resulting source (" & msg2.Source & ") should have been equal to " & msg.Source & ".")
        Debug.Print("Success: 'Source' properties are equal.")
        Assert.IsTrue(msg.Target = msg2.Target, "Result target should have been " & msg.Target)
        Debug.Print("Success: 'Target' properties are equal")
        Assert.IsTrue(msg.Hop = msg2.Hop, "Result hop count should have been " & msg.Hop)
        Debug.Print("Success: 'Hop' properties are equal")
        Assert.IsTrue(msg2.KeyValueList.Count = 0, "Key-value pair count = " & msg.KeyValueList.Count.ToString & ", while 0 was expected.")
        Debug.Print("Success: no key-value pairs, as expected.")

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErroneousSchema1()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH NO SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... no schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a missing schema in the message body.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErroneousSchema2()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... bad schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "this won't go for a schema")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a bad schema in the message body.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErroneousPartid1()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... missing schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        'msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "some.schema")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a missing partid key.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If
    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErroneousPartid2()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD PARTID IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... bad partid")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "some.schema")

        ' set bad values and test
        msg.KeyValueList("partid") = "/2:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "x/2:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/x:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/2:"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "12:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/235"
        PartidSubTest(msg)
        msg.KeyValueList.Remove(msg.KeyValueList.IndexOf("partid"))
        PartidSubTest(msg)
        Debug.Print("Success: correct exceptions thrown for bad partids")
    End Sub
    Private Sub PartidSubTest(ByVal msg As xPLMessage)
        Dim target As xPLFragmentedMsg
        Try
            target = New xPLFragmentedMsg(msg, xDev) ' create message from 1st fragment
            If msg.KeyValueList.IndexOf("partid") <> -1 Then
                Assert.Fail("Exception expected but not thrown for message with bad partid; '" & msg.KeyValueList("partid") & "'.")
            Else
                Assert.Fail("Exception expected but not thrown for message with missing partid.")
            End If
        Catch ex As xPLFragmentedMsg.FragmentationException
            If msg.KeyValueList.IndexOf("partid") <> -1 Then
                Debug.Print("Bad partid '" & msg.KeyValueList("partid") & "' threw correct exception.")
            Else
                Debug.Print("Missing partid threw correct exception.")
            End If
        Catch ex As AssertFailedException
            Throw
        Catch ex As Exception
            Debug.Print("Got exception: " & ex.ToString)
            Assert.Fail("Wrong exception, expected a FragmentationException for a bad partid.")
        End Try
    End Sub

    <TestMethod()> _
    Public Sub AutoFragmentTest()
        Dim msg As New xPLMessage
        Dim MSGID As String = "AutoFragmentTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        For n = 0 To 29
            msg.KeyValueList.Add("testky" & n.ToString, New String("A"c, 1000))
        Next
        xDev.AutoFragment = True
        yDev.AutoFragment = True
        Debug.Print("Sending a message that must be fragmented...")
        Debug.Print(msg.ToString())
        Debug.Print("")

        xDev.Send(msg)
        Dim expected As String = msg.RawxPL

        msg = WaitForTestKey(yDev, MSGID, 10000)
        Assert.IsNotNull(msg, "Message expected, got Null/Nothing, receiving the requested ID timed-out")
        Debug.Print("Received the test message...")
        Debug.Print(msg.ToString())
        Debug.Print("")

        Dim actual As String = msg.RawxPL
        Assert.AreEqual(expected, actual, "Received RawxPL does not match the send xPL, message malformed during transmission.")
        Debug.Print("Success; message received and reassembled succesfully, RawxPL string of send and received message are equal.")

        Assert.IsNull(CheckForFragmentSchema, "devices x/y received a message with schema 'fragment.xyz', which shouldn't be the case as the devices have been set to AutoFragment")
        Debug.Print("Success; no 'fragment.xyz' messages have been received by the x/y test devices.")
        Debug.Print("Test complete.")
    End Sub

    ''' <summary>
    ''' Checks the provided message list for messages with schema class 'Fragment' and returns the first message found.
    ''' If no list is provided then both yMessageList and xMessageList will be traversed while searching.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function CheckForFragmentSchema(Optional ByVal ListToSearch As Collection = Nothing) As xPLMessage
        Dim s As xPLSchema
        If ListToSearch Is Nothing Then
            For Each msg As xPLMessage In yMessageList
                s = New xPLSchema(msg.Schema)
                If s.SchemaClass = "fragment" Then
                    Return msg
                End If
            Next
            For Each msg As xPLMessage In xMessageList
                s = New xPLSchema(msg.Schema)
                If s.SchemaClass = "fragment" Then
                    Return msg
                End If
            Next
        Else
            For Each msg As xPLMessage In ListToSearch
                s = New xPLSchema(msg.Schema)
                If s.SchemaClass = "fragment" Then
                    Return msg
                End If
            Next
        End If
        Return Nothing
    End Function

    <TestMethod()> _
    Public Sub AutoFragmentFailTest()
        Dim msg As New xPLMessage
        Dim MSGID As String = "AutoFragmentFailTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        ' add a key with max message size length, hence cannot be fragmented
        msg.KeyValueList.Add("somekey", New String("A"c, XPL_MAX_MSG_SIZE))
        xDev.AutoFragment = True
        yDev.AutoFragment = True
        Debug.Print("Sending a message that must be fragmented... but can't")
        Debug.Print(msg.ToString())
        Debug.Print("")

        ' message is too large, so should throw exception
        Try
            xDev.Send(msg)
            Assert.Fail("Fragmentation exception was expected as the value was too large, but wasn't thrown")
        Catch ex As Exception
            Assert.IsTrue(TypeOf ex Is xPLFragmentedMsg.FragmentationException, "Fragmentation exception was expected, but instead a different exception was thrown; " & ex.ToString)
        End Try
        Debug.Print("Success; correct fragmentation exception was thrown.")
    End Sub


    <TestMethod()> _
    Public Sub RequestMissingPartsTest()
        Dim msg As New xPLMessage
        Dim fmsg As xPLFragmentedMsg
        Dim MSGID As String = "MissingPartsTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        For n = 0 To 2
            msg.KeyValueList.Add("testky" & n.ToString, New String("A"c, 1000))
        Next
        xDev.AutoFragment = False
        yDev.AutoFragment = True
        Debug.Print("Creating fragmented message...")
        Debug.Print(msg.ToString())
        fmsg = New xPLFragmentedMsg(msg, xDev)
        Debug.Print("")
        Debug.Print("Message parts;")
        For n As Integer = 1 To fmsg.Count
            Debug.Print("Part " & n & "/" & fmsg.Count)
            Debug.Print(fmsg.Fragment(n).ToString)
            Debug.Print("")
        Next
        Debug.Print("")
        Debug.Print("")
        Debug.Print("Now sending message part 3, part 1 and 2 will not be sent.")
        fmsg.Fragment(3).Send(xDev)
        Debug.Print("Message send by xDev...  now waiting for the resend request from yDev")

        Dim expire As Date = Now.AddSeconds(10)
        Dim request As xPLMessage = Nothing
        While expire > Now
            Threading.Thread.Sleep(300)
            ' check whats been received
            Try
                For Each x As xPLMessage In xMessageList
                    If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                        request = x
                        expire = Now.AddSeconds(-1)
                    End If
                Next
            Catch ex As Exception
            End Try
        End While
        Debug.Print("Messages received by xDev;")
        For Each x As xPLMessage In xMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")
        Debug.Print("Messages received by yDev;")
        For Each x As xPLMessage In yMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")

        Assert.IsNotNull(request, "No 'fragment.request' message was received by xDev from yDev. Should happen after 3 seconds, timedout after 10 seconds")
        Debug.Print("Success: 'fragment.request' has been received. Message: " & vbCrLf & request.ToString & vbCrLf)

        Assert.IsTrue(fmsg.MessageID = request.Target & ":" & request.KeyValueList("message"), "The proper ID was not found for the message")
        Debug.Print("Success: correct message ID detected in request message")
        _Assert(request.KeyValueList("command") = "resend", "Request must contain key/value; 'command=resend'.")
        For n As Integer = 0 To request.KeyValueList.Count - 1
            If request.KeyValueList(n).Key = "part" Then
                Dim v As String = request.KeyValueList(n).Value
                Assert.IsTrue(v <> "3", "Part 3 was requested, which was originally send, so its a bad request")
                Assert.IsTrue(v = "1" Or v = "2", "Unknown part '" & v & "' was requested.")
            End If
        Next
        Debug.Print("Now sending missing parts 2 and 1 (that order) through xDev, waiting for reassembled message to come in on yDev")
        fmsg.Fragment(2).Send(xDev)
        fmsg.Fragment(1).Send(xDev)
        Dim rm As xPLMessage = WaitForTestKey(yDev, MSGID)
        _Assert(rm IsNot Nothing, "The reassembled message was must be received by yDev and not timeout")
        _Assert(rm.RawxPL = msg.RawxPL, "Reassembled message must be equal (RawxPL) to the original message send.")
        'Debug.Print("Success: reassembled message equals the send message.")
        Debug.Print("Test complete.")
    End Sub

    ''' <summary>
    ''' When a message is sent, can missing parts be requested, and until how long...
    ''' </summary>
    ''' <remarks></remarks>
    <TestMethod()> _
    Public Sub PartRequestTest()
        Dim msg As New xPLMessage
        Dim fmsg As xPLFragmentedMsg
        Dim MSGID As String = "PartRequestTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        For n = 0 To 2
            msg.KeyValueList.Add("testky" & n.ToString, New String("A"c, 1000))
        Next
        xDev.AutoFragment = True
        yDev.AutoFragment = False
        Debug.Print("Creating fragmented message...")
        Debug.Print(msg.ToString())
        fmsg = New xPLFragmentedMsg(msg, xDev)
        Debug.Print("")
        Debug.Print("Message parts;")
        For n As Integer = 1 To fmsg.Count
            Debug.Print("Part " & n & "/" & fmsg.Count)
            Debug.Print(fmsg.Fragment(n).ToString)
            Debug.Print("")
        Next

        Debug.Print("")
        Debug.Print("")
        Debug.Print("Now sending message...")
        fmsg.Send()
        Debug.Print("Message send by xDev...  xDev should retain fragments for " & (XPL_FRAGMENT_SEND_RETAIN / 1000) & " seconds.")

        Dim request As New xPLMessage
        With request
            .MsgType = xPLMessageTypeEnum.Command
            .Source = yDev.Address
            .Target = xDev.Address
            .Schema = "fragment.request"
            With .KeyValueList
                .Add("command", "resend")
                .Add("message", Mid(fmsg.MessageID, Len(xDev.Address) + 2))
                .Add("part", "1")
            End With
        End With

        Debug.Print("waiting until it almost expires...")
        Threading.Thread.Sleep(XPL_FRAGMENT_SEND_RETAIN - 1000)
        Debug.Print("Clearing queues and sending resend request ...")
        xMessageList.Clear()
        yMessageList.Clear()
        request.Send(yDev)
        Debug.Print("Waiting for resend request to be answered... (max 10 seconds)")
        ' wait for resend request to be answered
        Dim expire As Date = Now.AddSeconds(10)
        Dim receivedfragment As xPLMessage = Nothing
        Dim partid = "1/" & fmsg.Count & ":" & Mid(fmsg.MessageID, Len(xDev.Address) + 2)
        While expire > Now
            Threading.Thread.Sleep(300)
            ' check whats been received
            Try
                For Each x As xPLMessage In yMessageList
                    If x.Schema = "fragment.basic" And x.Source = xDev.Address AndAlso x.KeyValueList("partid") = partid Then
                        receivedfragment = x
                        expire = Now.AddSeconds(-1)
                    End If
                Next
            Catch ex As Exception
            End Try
        End While
        Debug.Print("Messages received by xDev;")
        For Each x As xPLMessage In xMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")
        Debug.Print("Messages received by yDev;")
        For Each x As xPLMessage In yMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")

        _Assert(receivedfragment IsNot Nothing, "The requested fragment, resended by xDev must be received by yDev")
        Debug.Print("Now wait again, enough to make it expire, so the xDev will clean it up and the fragment will no longer be resend.")

        Threading.Thread.Sleep(XPL_FRAGMENT_SEND_RETAIN + 1000)
        Debug.Print("Clearing queues and sending resend request ...")
        xMessageList.Clear()
        yMessageList.Clear()
        request.Send(yDev)
        Debug.Print("Waiting for resend request to be answered... (max 10 seconds)")
        ' wait for resend request to be answered
        expire = Now.AddSeconds(10)
        receivedfragment = Nothing
        Dim log As xPLMessage = Nothing
        partid = "1/" & fmsg.Count & ":" & Mid(fmsg.MessageID, Len(xDev.Address) + 2)
        While expire > Now
            Threading.Thread.Sleep(300)
            ' check whats been received
            Try
                For Each x As xPLMessage In yMessageList
                    If x.Schema = "fragment.basic" And x.Source = xDev.Address AndAlso x.KeyValueList("partid") = partid Then
                        receivedfragment = x
                        expire = Now.AddSeconds(-1)
                    End If
                    If x.Schema = "log.basic" And x.Source = xDev.Address Then
                        log = x
                        expire = Now.AddSeconds(-1)
                    End If
                Next
            Catch ex As Exception
            End Try
        End While
        Debug.Print("Messages received by xDev;")
        For Each x As xPLMessage In xMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")
        Debug.Print("Messages received by yDev;")
        For Each x As xPLMessage In yMessageList
            Debug.Print("from: " & x.Source & ", schema: " & x.Schema)
            If x.Schema = "fragment.request" And x.Source = yDev.Address Then
                request = x
                expire = Now.AddSeconds(-1)
            End If
        Next
        Debug.Print("")

        _Assert(receivedfragment Is Nothing, "The requested fragment, must be expired and no longer be resended by xDev.")
        _Assert(log IsNot Nothing, "A log.basic message must be send if a request for an unknown fragment/message is made.")

        Debug.Print("Test complete.")
    End Sub

    ''' <summary>
    ''' Test that fragments that are received, but remain incomplete are cleaned-up
    ''' </summary>
    ''' <remarks></remarks>
    <TestMethod()> _
        Public Sub DismissIncompleteTest()

        ' create a 3 part message
        Dim msg As New xPLMessage
        Dim fmsg As xPLFragmentedMsg
        Dim MSGID As String = "DimissIncompleteTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        For n = 0 To 2
            msg.KeyValueList.Add("testky" & n.ToString, New String("A"c, 1000))
        Next
        xDev.AutoFragment = False
        yDev.AutoFragment = True
        Debug.Print("Creating fragmented message...")
        Debug.Print(msg.ToString())
        fmsg = New xPLFragmentedMsg(msg, xDev)
        Debug.Print("")
        Debug.Print("Message parts;")
        For n As Integer = 1 To fmsg.Count
            Debug.Print("Part " & n & "/" & fmsg.Count)
            Debug.Print(fmsg.Fragment(n).ToString)
            Debug.Print("")
        Next

        Debug.Print("")
        Debug.Print("")
        Debug.Print("Now sending message... parts 1 and 2")

        ' send 2 parts
        fmsg.Fragment(1).Send()
        fmsg.Fragment(2).Send()
        ' wait for timeouts to expire
        Threading.Thread.Sleep(XPL_FRAGMENT_REQUEST_AFTER + XPL_FRAGMENT_REQUEST_TIMEOUT + 1000)
        Debug.Print("by now the 2 message fragments should have been deleted by yDev, sending last part...")
        ' send 3rd part
        fmsg.Fragment(3).Send()
        Debug.Print("No wait to see if yDev receives the defragmented message (which it shouldn't)")
        msg = WaitForTestKey(xDev, MSGID, XPL_FRAGMENT_REQUEST_AFTER + XPL_FRAGMENT_REQUEST_TIMEOUT + 1000)
        ' if message is completed, it wasn't cleaned up properly
        Assert.IsNull(msg, "The fragmented message was received, instead of the first fragments having been deleted...")
        Debug.Print("Success, no message received.")

    End Sub

    ''' <summary>
    ''' Test that fragments that are received, but remain incomplete are cleaned-up
    ''' </summary>
    ''' <remarks></remarks>
    <TestMethod()> _
        Public Sub BadFragmentTest()

        ' create a 3 part message
        Dim msg As New xPLMessage
        Dim fmsg As xPLFragmentedMsg
        Dim MSGID As String = "DimissIncompleteTest"

        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Source = xDev.Address
        msg.Target = yDev.Address
        msg.KeyValueList.Add(TESTKEY, MSGID)
        For n = 0 To 2
            msg.KeyValueList.Add("testky" & n.ToString, New String("A"c, 1000))
        Next
        xDev.AutoFragment = False
        yDev.AutoFragment = True

        Debug.Print("Creating fragmented message... without schema key")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(1).KeyValueList.Remove(fmsg.Fragment(1).KeyValueList.IndexOf("schema"))   ' remove schema key
        fmsg.Send()


        Debug.Print("Creating fragmented message... with bad schema key: 'this is no valid schema'")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(1).KeyValueList("schema") = "this is no valid schema"   ' bad schema key
        fmsg.Send()

        Debug.Print("Creating fragmented message... without partid (fragment 1 and 2)")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(1).KeyValueList.Remove(fmsg.Fragment(1).KeyValueList.IndexOf("partid"))   ' remove schema key
        fmsg.Fragment(2).KeyValueList.Remove(fmsg.Fragment(2).KeyValueList.IndexOf("partid"))   ' remove schema key
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: /2:35")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "/2:35"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: x/2:35")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "x/2:35"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: 1/:35")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "1/:35"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: 1/x:35")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "1/x:35"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: 1/2:")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "1/2:"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: 12:35")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "12:35"   ' bad part id
        fmsg.Send()

        Debug.Print("Creating fragmented message... with bad partid: 1/235")
        fmsg = New xPLFragmentedMsg(msg, xDev)
        fmsg.Fragment(2).KeyValueList("partid") = "1/235"   ' bad part id
        fmsg.Send()
    End Sub

End Class
