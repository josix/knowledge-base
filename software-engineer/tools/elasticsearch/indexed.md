---
title: "indexed"
date: 2022-05-06T02:07
dg-publish: true
dg-permalink: "software-engineer/tools/elasticsearch/indexed"
---
- Every field that is [[indexed]] in [[Lucene]] is converted into a fast search structure for its particular type.
	- The [[text field]] is split into tokens, if analyzed or saved as a single [[token]]
	- The [[numeric fields]] are converted into their fastest binary representation
	- The date and [[datetime fields]] are converted into binary forms