<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xsl:exclude-result-prefixes='ss'>
<xsl:output method="xml"/>
<xsl:template match="/">
  <xsl:apply-templates select="log"/>
</xsl:template>

<xsl:template match="log">
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
 <Styles>
  <Style ss:ID="s21">
   <Font ss:Bold="1"/>
  </Style>
 </Styles>
 <Worksheet ss:Name="XPLLog">
  <Table>
   <Row>
    <Cell ss:StyleID="s21"><Data ss:Type="String">msgtype</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">date/time</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">source vendor</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">source device</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">source instance</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">target vendor</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">target device</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">target instance</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">class</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">type</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">name</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">value</Data></Cell>
   </Row>
   <xsl:for-each select="xplmsg">
   <Row>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/msgtype" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="@logdate" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/source/vendor" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/source/device" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/source/instance" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/target/vendor" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/target/device" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="header/target/instance" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="schema/class" /></Data></Cell>
    <Cell><Data ss:Type="String"><xsl:value-of select="schema/type" /></Data></Cell>
   </Row>
	  <xsl:for-each select="schema/infopairs/info">
       <Row>
        <Cell ss:Index="11"><Data ss:Type="String"><xsl:value-of select="@name" /></Data></Cell>
        <Cell><Data ss:Type="String"><xsl:value-of select="@value" /></Data></Cell>
       </Row>
      </xsl:for-each>
   </xsl:for-each>
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <Panes>
    <Pane>
     <Number>1</Number>
     <ActiveRow>1</ActiveRow>
     <ActiveCol>1</ActiveCol>
    </Pane>
   </Panes>
  </WorksheetOptions>
 </Worksheet>
</Workbook>

</xsl:template>

</xsl:stylesheet>
