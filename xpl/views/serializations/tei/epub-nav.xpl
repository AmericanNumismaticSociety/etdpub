<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">	
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/tei/epub-nav.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/xhtml+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>