<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
<xsl:template match="/">
  <xsl:apply-templates select="log"/>
</xsl:template>

<xsl:template match="log">
<html>
	<head>
		<title>xPL Messages</title>
	</head>
	<body bgcolor="#d4d0c8" style="FONT-SIZE: 10px; FONT-FAMILY: Arial, Helvetica, sans-serif">
		<TABLE cellSpacing="4" cellPadding="1" width="300" border="0" bgcolor="#d4d0c8">
			<xsl:apply-templates select="xplmsg"/>
		</TABLE>
	</body>
</html>

</xsl:template>

<xsl:template match="xplmsg">
							  <xsl:param name="logbg">
							      <xsl:choose>
							        <xsl:when test="schema/class[translate(.,$lowercase,$uppercase)='LOG']">#ff0000</xsl:when>
								    <xsl:otherwise>#ffff66</xsl:otherwise>
								  </xsl:choose>
							  </xsl:param>
			<TR>
				<TD bgColor="#000000">
					<TABLE cellSpacing="0" cellPadding="0" width="100%" border="0">
						<TR>
							<TD width="50%" bgColor="#ffff66"><STRONG><xsl:value-of select="header/msgtype" /></STRONG>
							</TD>
							<TD width="50%" bgColor="#ffff66">
								<P align="right"><FONT size="2"><xsl:value-of select="@logdate" /></FONT></P>
							</TD>
						</TR>
						<tr>
							<td height="1" valign="top" colspan="2" bgcolor="#000000"></td>
						</tr>
						<TR>
							<TD width="50%" bgColor="#ffffcc">
								<P align="center"><FONT size="2"><STRONG>source</STRONG></FONT></P>
							</TD>
							<TD width="50%" bgColor="#ffffcc">
								<P align="center"><FONT size="2"><STRONG>target</STRONG></FONT></P>
							</TD>
						</TR>
						<TR>
							<TD width="50%" bgColor="#ffffcc">
								<DIV align="center">
									<TABLE cellSpacing="1" cellPadding="1" width="100" border="0" align="center">
										<TR>
											<TD width="33%"><FONT size="2"><xsl:value-of select="header/source/vendor" /></FONT></TD>
											<TD width="33%"><FONT size="2"><xsl:value-of select="header/source/device" /></FONT></TD>
											<TD width="34%"><FONT size="2"><xsl:value-of select="header/source/instance" /></FONT></TD>
										</TR>
									</TABLE>
								</DIV>
							</TD>
							<TD width="50%" bgColor="#ffffcc">
								<DIV align="center">
									<TABLE cellSpacing="1" cellPadding="1" width="100" border="0" align="center">
										<TR>
											<TD width="33%"><FONT size="2"><xsl:value-of select="header/target/vendor" /></FONT></TD>
											<TD width="33%"><FONT size="2"><xsl:value-of select="header/target/device" /></FONT></TD>
											<TD width="34%"><FONT size="2"><xsl:value-of select="header/target/instance" /></FONT></TD>
										</TR>
									</TABLE>
								</DIV>
							</TD>
						</TR>
						<tr>
							<td height="1" valign="top" colspan="2" bgcolor="#000000"></td>
						</tr>
						<TR>
							<TD width="50%">
							  <xsl:attribute name="bgcolor"><xsl:value-of select="$logbg"/></xsl:attribute>
							  <P align="center"><STRONG><xsl:value-of select="schema/class" /></STRONG></P>
							</TD>
							<TD width="50%">
							  <xsl:attribute name="bgcolor"><xsl:value-of select="$logbg"/></xsl:attribute>
							  <P align="center"><STRONG><xsl:value-of select="schema/type" /></STRONG></P>
							</TD>
						</TR>
						<tr>
							<td height="1" valign="top" colspan="2" bgcolor="#000000"></td>
						</tr>
							<xsl:apply-templates select="schema/infopairs/info"/>
					</TABLE>
				</TD>
			</TR>
</xsl:template>

<xsl:template match="schema/infopairs/info">
						<TR>
							<TD width="50%" bgColor="#ffffcc">
								<P align="center"><FONT size="2"><xsl:value-of select="@name" /></FONT></P>
							</TD>
							<TD width="50%" bgColor="#ffffcc">
								<P align="center"><FONT size="2"><xsl:value-of select="@value" /></FONT></P>
							</TD>
						</TR>
</xsl:template>

</xsl:stylesheet>
