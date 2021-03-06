# ETDPub
ETDPub was initialized designed as a lightweight Electronic Thesis and Disseration system. Data entry is written in XForms and powered by the [Orbeon XForms](http://www.orbeon.com) engine. Metadata are encoded in MODS, and the metadata and document files are indexed into Apache Solr for access in a public user interface that contains basic faceted search functionality. As part of the Mellon/NEH Open Humanities Book project, it has been extended to support the publication of TEI ebooks, in addition to the serialization of TEI into RDF, EPUB 3.0.1, and, most recently, Crossref's XML medata model. When ORCIDs have been connected to ebook or ETD authors/editors, the document metadata can be published to Crossref in order to mint a DOI.

ETDPub can optionally be connected to a SPARQL endpoint, which allows digital library content to be made available through accompanying digital archive frameworks, like [xEAC](https://github.com/ewg118/xEAC).

This framework is the backbone of the American Numismatic Society [Digital Library](http://numismatics.org/digitallibrary/)

Controlled Vocabulary
---------------------
The backend data entry system includes a variety of lookup mechanisms for MODS creator names and subject terms:

* Names: [VIAF](http://viaf.org/), [xEAC](https://github.com/ewg118/xEAC), [Nomisma.org](http://nomisma.org), [Getty ULAN](http://vocab.getty.edu/ulan/)
* Geographical names: [Geonames](http://www.geonames.org), [Pleiades](http://pleiades.stoa.org), [Getty TGN](http://vocab.getty.edu/tgn/)
* Temporal subjects: [Getty AAT](http://vocab.getty.edu/aat/)
* Topical subjects: [LCSH](http://id.loc.gov/authorities/subjects)
 
Export/Alternative Data Models and Serializations
-------------------------------------------------
In addition to making the MODS and TEI XML available for download, ETDPub provides alternative models (derived from both canonical XML documents and Solr query results):

* MODS->RDF/XML
* TEI->RDF/XML
* TEI->EPUB 3.0.1
* Solr->Atom
* Solr->Pelagios RDF/XML (for making content associated with ancient places defined by Pleiades)
* Solr->OAI-PMH

Linked Data
-----------
ETDPub optionally allows connection to an RDF triplestore and SPARQL endpoints to facilitate the publication of digital library materials in the form of linked open data.

Architecture
------------
ETDPub is comprised of three server-side application which run in Apache Tomcat: [Orbeon](http://www.orbeon.com) (XForms processor and public user interface), [Solr](http://lucene.apache.org/solr/) (search index used for publication), and [eXist](http://exist-db.org/exist/apps/homepage/index.html) (XML database).  XForms submissions allow these three applications to communicate through REST.

ORCID/DOIs
----------
ETDPub can be configured with Crossref configuration settings to mint DOIs for books, articles, and ETDs published in the system. The metadata should include an ORCID for authors or other contributors in order to be eligible for Crossref publication.

Installation and Use
--------------------
Please see the [wiki](https://github.com/AmericanNumismaticSociety/etdpub/wiki) for installation instructions.
