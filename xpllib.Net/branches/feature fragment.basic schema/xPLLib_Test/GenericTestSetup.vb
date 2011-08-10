Option Strict On

Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting
Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics

''' <summary>
''' Contains procedures, functions adn globals for test setup of devices, device lists and other functions
''' </summary>
''' <remarks></remarks>
Module GenericTestSetup
    Friend Const TESTKEY As String = "testkey"
    Friend WithEvents xDev As xPLDevice
    Friend WithEvents yDev As xPLDevice
    Friend xMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey
    Friend yMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey

    Friend Sub xPLTestInitialize()
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

    Public Sub xPLTestCleanup()
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
    ''' Wait for a message to arrive with a specific testkey, returns the message, or Nothing if it times out
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="TestKeyValue"></param>
    ''' <param name="TimeOut">Timeout in milliseconds</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Friend Function WaitForTestKey(ByVal sender As xPLDevice, ByVal TestKeyValue As String, Optional ByVal TimeOut As Integer = 5000) As xPLMessage
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

End Module
