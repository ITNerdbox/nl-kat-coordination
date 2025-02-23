=======
Modules
=======

OpenKAT consists of individual modules, each of which performs a subtask of the system. The modules are specific to OpenKAT. Rocky is the frontend, Mula is the scheduler, Bytes the storage of raw data, Octopoes contains the data model, Keiko is the PDF engine for reports and Boefjes and Whiskers and are separate components stored in the KATalogus. OpenKAT uses Manon for the design in order to easily comply with accessibility and style requirements.

The source code and technical documentation is included for each module in its own github repository. This document refers to these repos and their documentation. If you have any questions, please contact the team, see 'Contact' in the readme of the NL-KAT-Coordination repo.

Rocky
=====

Rocky is the front end for OpenKAT and based on a Django framework. Through Rocky, OpenKAT can be accessed. It provides a user interface for all information present in the system. It is also possible to access OpenKAT only through the APIs.

`NL-KAT-rocky <https://github.com/minvws/nl-kat-rocky>`_ is the repository containing Rocky's source code and documentation.

Mula
====

Mula is the scheduler, which controls OpenKAT. Mula has extensive technical documentation and design schematics.

`NL-KAT-mula <https://github.com/minvws/nl-kat-mula>`_ is the repository containing Mula's source code and documentation.

Octopoes
========

Octopoes contains the data model and the XTDB with all objects. The documentation accompanying Octopoes covers the technical side of the logic behind OpenKAT and includes extensive information for people who want to work with the data model themselves.

`NL-KAT-octopoes <https://github.com/minvws/nl-kat-octopoes>`_ is the repostory containing the source code and documentation of Octopoes.

Bytes
=====

Bytes is a relatively simple datastore for the raw data provided by OpenKAT. In addition to storage, Bytes also handles assurance by having a timestamp created from the stored data.

`NL-KAT-bytes <https://github.com/minvws/nl-kat-bytes>`_ is the repository containing Bytes' source code and documentation.

Boefjes and whiskers
====================

The KATalog contains all boefjes and whiskers. The KATalog is easy to add new boefjes and normalizers. The general documentation contains some pointers for writing boefjes. The team is happy to help you if you want to get started with these. The readme of `NL-KAT-Coordination repo <https://github.com/minvws/nl-kat-coordination>`_. contains all the ways to contact the team.

`NL-KAT Boefjes <https://github.com/minvws/nl-kat-boefjes>`_ is the repository containing the source code and documentation of Boefjes, Whiskers and Bits.

Keiko
=====

Keiko is OpenKAT's PDF generator, used for generating reports. The design of the reports is done based on a LaTeX template, making the style of the reports customizable.

`NL-KAT-Keiko <https://github.com/minvws/nl-kat-keiko>`_ is the repository containing Keiko's source code.

Manon
=====

Content and form are separated in Rocky. The form is contained in Manon, which as far as OpenKAT is applied in the context of the central government helps to comply with the central government house style. For Web sites outside this context, Manon is also applicable, but with a different style.

`NL-RDO-Manon <https://github.com/minvws/nl-rdo-manon>`_ is the repository containing Manon's source code.


