<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="config-xml" href="#config"/>
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/mods/crossref.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
