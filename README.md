# README

This is just a temporary repository for Aida web porting works.
It was generated by filing out package categories and generating
the .st files and then converting carriage returns to newlines.

The packages installed in the image were taken from the evaluation
of this code in a workspace:

```smalltalk
i := Installer monticello http: 'http://squeaksource.com'.
i  project: 'SPort';
    install: 'Sport-2.031'.
i  project: 'Swazoo';
    install: 'Swazoo-2.4final.2'.
i  project: 'Aida';
    install: 'Aida-6.8final.2'.
```

A aida_20200525.image was saved but for some reason it froze.
This repository is only intended to provide a base for porting
to Aida. The initial author of this readme and the inital fileouts
has other interests than porting aida to cuis.