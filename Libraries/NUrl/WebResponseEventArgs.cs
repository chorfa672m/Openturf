﻿#region Copyright

// Professional Twitter Development by Daniel Crenna (ISBN 978-0-470-53132-7)
// Copyright Wiley Publishing Inc, 2009. 
// Please refer to http://www.wrox.com/WileyCDA/Section/id-106010.html for licensing terms.

#endregion

using System;

namespace Wrox.Twitter.NUrl
{
    public class WebResponseEventArgs : EventArgs
    {
        public Uri Uri { get; set; }
        public string Response { get; set; }
    }
}