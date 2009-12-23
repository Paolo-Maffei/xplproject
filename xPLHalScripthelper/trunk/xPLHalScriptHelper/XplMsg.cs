//* xPL Library for .NET
//* xPLMsg Class
//*
//* Version 4.4
//*
//* Copyright (c) 2008 Tom Van den Panhuyzen
//* http://blog.boxedbits.com/xpl
//*
//* Copyright (C) 2003-2005 John Bent
//* http://www.xpl.myby.co.uk
//*
//*
//* This program is free software; you can redistribute it and/or
//* modify it under the terms of the GNU General Public License
//* as published by the Free Software Foundation; either version 2
//* of the License, or (at your option) any later version.
//* 
//* This program is distributed in the hope that it will be useful,
//* but WITHOUT ANY WARRANTY; without even the implied warranty of
//* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//* GNU General Public License for more details.
//*
//* You should have received a copy of the GNU General Public License
//* along with this program; if not, write to the Free Software
//* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//* Linking this library statically or dynamically with other modules is
//* making a combined work based on this library. Thus, the terms and
//* conditions of the GNU General Public License cover the whole
//* combination.
//* As a special exception, the copyright holders of this library give you
//* permission to link this library with independent modules to produce an
//* executable, regardless of the license terms of these independent
//* modules, and to copy and distribute the resulting executable under
//* terms of your choice, provided that you also meet, for each linked
//* independent module, the terms and conditions of the license of that
//* module. An independent module is a module which is not derived from
//* or based on this library. If you modify this library, you may extend
//* this exception to your version of the library, but you are not
//* obligated to do so. If you do not wish to do so, delete this
//* exception statement from your version.

using System.Collections.Generic;
using System.Net;
using Microsoft.Win32;
using System.Net.Sockets;
using System.Text.RegularExpressions;
using System;

//* The XplMsg class represents a single XPL message.
//* As such, it provides methods for constructing, analysing,
//* and sending an XPL message.
public class XplMsg {

    public enum xPLMsgType {
        trig,
        stat,
        cmnd
    }

    /// <exclude/>
    public class KeyValuePair {
        private string mKey;
        private string mValue;

        public KeyValuePair(string k, string v) {
            mKey = k;
            mValue = v;
        }

        public string Key {
            get { return mKey; }
            set {
                if (CheckString(value, 1, 8, true)) {
                    mKey = value;
                } else {
                    throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
                }
            }
        }

        public string Value {
            get { return mValue; }
            set {
                if (CheckString(value, 0, 128, false)) {
                    mValue = value;
                } else {
                    throw new IllegalFieldContentsException("Illegal field length (0 to 128)");
                }
            }
        }
    }

    private const bool DefaultStrictInterpretation = false;
    static bool mStrictInterpretation;
    private xPLMsgType mXplMsgType;
    private string mSourceVendor;
    private string mSourceDevice;
    private string mSourceInstance;
    private string mTargetVendor;
    private string mTargetDevice;
    private string mTargetInstance;
    private bool mTargetIsAll;
    private string mClass;
    private string mType;
    private List<KeyValuePair> mKeysValues;
    private string mRawXPL;
    private bool mValidRawXPL;

    private bool mExtractedOldWay;

    private const int XPL_BASE_PORT = 3865;
    private static IPAddress pBroadcastAddress;

    public XplMsg() {
        mStrictInterpretation = DefaultStrictInterpretation;
        mXplMsgType = xPLMsgType.cmnd;
        mTargetIsAll = true;
        mKeysValues = new List<KeyValuePair>();
        mValidRawXPL = false;

        mExtractedOldWay = false;
        //to be removed in future versions
        //to be removed in future versions
        //XPL_Raw = "";
    }

    public XplMsg(string rawXplMsg) {
        mStrictInterpretation = DefaultStrictInterpretation;
        if (!ExtractContents(rawXplMsg)) {
            throw new InvalidXPLMessageException();
        }

        mExtractedOldWay = false;
        //to be removed in future versions
        //to be removed in future versions
        //XPL_Raw = rawXplMsg;
    }

    public XplMsg(string rawXplMsg, bool AllowUppercase) {
        mStrictInterpretation = !AllowUppercase;
        if (!ExtractContents(rawXplMsg)) {
            throw new InvalidXPLMessageException();
        }

        mExtractedOldWay = false;
        //to be removed in future versions
        //to be removed in future versions
        //XPL_Raw = rawXplMsg;
    }

    public bool AllowUppercaseFromNetwork {
        get { return !mStrictInterpretation; }
        set { mStrictInterpretation = !value; }
    }

    public xPLMsgType MsgType {
        get { return mXplMsgType; }
        set { mXplMsgType = value; }
    }


    public string MsgTypeString {
        get {
            switch (mXplMsgType) {
                case xPLMsgType.cmnd:
                    return "xpl-cmnd";
                case xPLMsgType.stat:
                    return "xpl-stat";
                case xPLMsgType.trig:
                    return "xpl-trig";
            }
            return "";
        }
    }

    public string SourceVendor {
        get { return mSourceVendor; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mSourceVendor = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
        }
    }

    public string SourceDevice {
        get { return mSourceDevice; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mSourceDevice = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
        }
    }

    public string SourceInstance {
        get { return mSourceInstance; }
        set {
            if (CheckString(value, 1, 16, true)) {
                mSourceInstance = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 16) or illegal casing");
            }
        }
    }

    public string SourceTag {
        get { return mSourceVendor + "-" + mSourceDevice + "." + mSourceInstance; }
    }

    public string TargetVendor {
        get { return mTargetVendor; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mTargetVendor = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
            if (value == "*") mTargetIsAll = true;
        }
    }

    public string TargetDevice {
        get { return mTargetDevice; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mTargetDevice = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
            if (value == "*") mTargetIsAll = true;
        }
    }

    public string TargetInstance {
        get { return mTargetInstance; }
        set {
            if (CheckString(value, 1, 16, true)) {
                mTargetInstance = value;
                if (value == "*") mTargetIsAll = true;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 16) or illegal casing");
            }
        }
    }

    public string TargetTag {
        get {
            if (TargetIsAll) {
                return "*";
            } else {
                return mTargetVendor + "-" + mTargetDevice + "." + mTargetInstance;
            }
        }
    }

    public bool TargetIsAll {
        get { return mTargetIsAll; }
        set {
            mTargetIsAll = value;
            if (value) {
                mTargetVendor = "*";
                mTargetDevice = "*";
                mTargetInstance = "*";
            }
        }
    }

    public string Class {
        get { return mClass; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mClass = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
        }
    }

    public string Type {
        get { return mType; }
        set {
            if (CheckString(value, 1, 8, true)) {
                mType = value;
            } else {
                throw new IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing");
            }
        }
    }

    public void AddKeyValuePair(ref KeyValuePair KeyValue) {
        mKeysValues.Add(KeyValue);
    }

    public void AddKeyValuePair(string Key, string Value) {
        mKeysValues.Add(new KeyValuePair(Key, Value));
    }

    public List<KeyValuePair> KeyValues {
        get { return mKeysValues; }
    }

    public string GetKeyValue(string Key) {

        foreach (KeyValuePair kv in mKeysValues) {
            if (kv.Key.ToLower() == Key) {
                return kv.Value;
            }
        }

        return "";
    }

    public string RawXPL {
        get {
            if (!mValidRawXPL) {
                //check if all fields supplied

                if (RequiredFieldsFilled()) {
                    mRawXPL = BuildXplMsg();
                    mValidRawXPL = true;
                } else {
                    throw new MissingFieldsException("Unable to construct valid xPL from supplied fields.");
                }
            }
            return mRawXPL;
        }
        set {
            if (!ExtractContents(value)) {
                throw new InvalidXPLMessageException();
            }
        }
    }

    private string BuildXplMsg() {
        string s = "";

        switch (mXplMsgType) {
            case xPLMsgType.cmnd:
                s = "xpl-cmnd" + "\r\n" + "{" + "\r\n" + "hop=1" + "\r\n";
                break;
            case xPLMsgType.stat:
                s = "xpl-stat" + "\r\n" + "{" + "\r\n" + "hop=1" + "\r\n";
                break;
            case xPLMsgType.trig:
                s = "xpl-trig" + "\r\n" + "{" + "\r\n" + "hop=1" + "\r\n";
                break;
        }

        s += "source=" + SourceTag + "\r\n";
        s += "target=" + TargetTag + "\r\n";
        s += "}" + "\r\n" + mClass + "." + mType + "\r\n" + "{" + "\r\n";

        foreach (KeyValuePair kv in mKeysValues) {
            s += kv.Key + "=" + kv.Value + "\r\n";
        }

        s += "}" + "\r\n";

        return s;
    }

    //test the string: is it too long, and if it has to be lowercase, is it lowercase ?
    public static bool CheckString(string theString, int minlen, int maxlen, bool lower) {
        bool ok = true;

        if (theString.Length > maxlen | theString.Length < minlen) ok = false;
        if (ok && lower && theString.ToLower() != theString) ok = false;

        return ok;
    }

    private bool RequiredFieldsFilled() {
        if (mSourceVendor.Length > 0 & mSourceDevice.Length > 0 & mSourceInstance.Length > 0 & (mTargetIsAll | (mTargetVendor.Length > 0 & mTargetDevice.Length > 0 & mTargetInstance.Length > 0)) & mClass.Length > 0 & mType.Length > 0) {
            return true;
        } else {
            return false;
        }
    }

    private bool ExtractContents(string themsg) {
        Regex r = default(Regex);
        bool ok = false;

        if (mStrictInterpretation) {
            //no uppercase allowed


            r = new Regex("^xpl-(?<msgtype>trig|stat|cmnd)\\n" + "\\{\\n" + "(?:hop=\\d\\n" + "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\\.(?<si>[0-9a-z/-]{1,16})\\n" + "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\\.(?<ti>[0-9a-z/-]{1,16})|\\*)\\n){3}" + "\\}\\n" + "(?<class>[0-9a-z/-]{1,8})\\.(?<type>[0-9a-z/-]{1,8})\\n" + "\\{\\n" + "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\\x20-\\x7E]{0,128})\\n)*" + "\\}\\n$", RegexOptions.Compiled | RegexOptions.Singleline);
        } else {
            //mixed case allowed


            r = new Regex("^xpl-(?<msgtype>trig|stat|cmnd)\\n" + "\\{\\n" + "(?:hop=\\d\\n" + "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\\.(?<si>[0-9a-z/-]{1,16})\\n" + "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\\.(?<ti>[0-9a-z/-]{1,16})|\\*)\\n){3}" + "\\}\\n" + "(?<class>[0-9a-z/-]{1,8})\\.(?<type>[0-9a-z/-]{1,8})\\n" + "\\{\\n" + "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\\x20-\\x7E]{0,128})\\n)*" + "\\}\\n$", RegexOptions.Compiled | RegexOptions.Singleline | RegexOptions.IgnoreCase);
        }

        Match m = r.Match(themsg);
        if (m.Success) {
            switch (m.Groups["msgtype"].Captures[0].Value.ToLower()) {
                case "trig":
                    mXplMsgType = xPLMsgType.trig;
                    break;
                case "cmnd":
                    mXplMsgType = xPLMsgType.cmnd;
                    break;
                case "stat":
                    mXplMsgType = xPLMsgType.stat;
                    break;
            }

            mSourceVendor = m.Groups["sv"].Captures[0].Value;
            mSourceDevice = m.Groups["sd"].Captures[0].Value;
            mSourceInstance = m.Groups["si"].Captures[0].Value;

            if (m.Groups["target"].Captures[0].Value == "*") {
                mTargetIsAll = true;
                mTargetVendor = "*";
                mTargetDevice = "*";
                mTargetInstance = "*";
            } else {
                mTargetIsAll = false;
                mTargetVendor = m.Groups["tv"].Captures[0].Value;
                mTargetDevice = m.Groups["td"].Captures[0].Value;
                mTargetInstance = m.Groups["ti"].Captures[0].Value;
            }

            mClass = m.Groups["class"].Captures[0].Value;
            mType = m.Groups["type"].Captures[0].Value;

            int ival = 0;
            mKeysValues = new List<KeyValuePair>();

            foreach (Capture c in m.Groups["key"].Captures) {
                mKeysValues.Add(new KeyValuePair(c.Value, m.Groups["val"].Captures[ival].Value));
                ival += 1;
            }

            mRawXPL = themsg;
            mValidRawXPL = true;
            ok = true;
        }


        return ok;
    }

    #region "Definition of Exceptions"
    /// <summary>
    /// 
    /// </summary>
    /// <exclude/>
    public class IllegalFieldContentsException : System.Exception {

        public IllegalFieldContentsException()
            : base() {
        }

        public IllegalFieldContentsException(string message)
            : base(message) {
        }

        public IllegalFieldContentsException(string message, Exception inner)
            : base(message, inner) {
        }
    }

    /// <exclude/>
    public class InvalidXPLMessageException : System.Exception {

        public InvalidXPLMessageException()
            : base() {
        }

        public InvalidXPLMessageException(string message)
            : base(message) {
        }

        public InvalidXPLMessageException(string message, Exception inner)
            : base(message, inner) {
        }
    }

    /// <exclude/>
    public class MissingFieldsException : System.Exception {

        public MissingFieldsException()
            : base() {
        }

        public MissingFieldsException(string message)
            : base(message) {
        }

        public MissingFieldsException(string message, Exception inner)
            : base(message, inner) {
        }
    }

    #endregion
}
