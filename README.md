intervention
============

A simple proxy management structure that can contain several proxies that can handle multiple transactions.
Each proxy can be configured to run a block of code upon a request or response being made.

Intervention has the ability to add 'interventions', Calls to external modules, classes and objects.

# Getting started

## setup
Intervention is a gem, to add it to your system run the following:
```
gem install intervention
```
## Using intervention

To use intervention in your code, require intervention at the start of your file.
```
require 'intervention'
```

### Starting a new proxy
Starting a new proxy can be done in one of two simple ways
#### Passing arguments

#### Passing a block
