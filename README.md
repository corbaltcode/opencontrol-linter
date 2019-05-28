[![CircleCI](https://circleci.com/gh/corbaltcode/opencontrol-linter.svg?style=svg)](https://circleci.com/gh/corbaltcode/opencontrol-linter)


**Open Control Linter** is a linter for the OpenControl standard of security controls. 
Use it to check the correctness of opencontrols components, standards and certifications quickly.

To find out more about opencontrol see:
https://open-control.org/

## Features

Linter currently checks for
- Schema Compliance with the OpenControl schema standards
  - Components 1.0, 2.0, 3.0, 3.1
  - Standards 1.0
  - Certifications 1.0
  - Manifest (opencontrol.yaml) 1.0
- Missing a required item in a manifest, component, standard or certification file
- Additional items that are not allowed according to the schema you specify
- Incorrect or misspelled items in required enumerations
- Broken links to your components
- Incorrectly specified schema version
- Missing OpenControl files
- and others


## Installation

```sh
$ gem install opencontrol-linter
```

If you'd rather install Open Control Linter using `bundler`, don't require it in your `Gemfile`:

```rb
gem 'opencontrol-linter', require: false
```

## Quickstart

Just type `opencontrol-linter` in a control project root directory.

```
$ cd awesome/opencontrols/
$ opencontrol-linter
```

## Documentation

Detailed command line arguments

```
 usage: opencontrol-linter

  optional arguments:
    -h, --help            show this help message and exit
    -c, --components
                          Specify component files should be checked. Defaults to
                          true. Searches ./**/component.yaml or the search you
                          optionally specify.
    -n, --certifications
                          Specify certification (eg FISMA high)files should be
                          checked. Defaults to true. Searches
                          ./certifications/*.yaml or the search you optionally
                          specify.
    -s, --standards
                          Specify standard files (eg NIST 800.53) should be
                          checked. Defaults to true. Searches ./standards/*.yaml
                          or the search you optionally specify.
    -a, --all             Run all types of validations (this is the default).
    -v, --version         Show the version of this utility.

      
```

Usage examples

```
# lint all components, standards and certifications in the current directory
opencontrol-linter

# lint all components subdir components
opencontrol-linter --components './components/**/component.yaml'

# lint all standards files found
opencontrol-linter --standards

# lint one component
opencontrol-linter --components './components/AU_policy/component.yaml'

```

## Search Paths

The search paths will be loaded from the opencontrol.yaml file if it is available.

In the case that there is no opencontrol.yaml, by default the linter will search in the following paths. 

These paths can all be overridden on the command line or in the opencontrol.yaml file.
```
components:        '**/component.yaml'       (recursive search for files named component)
standards:         './standards/*.yaml'
certifications:    './certifications/*.yaml'
opencontrol files: './opencontrol.yaml'

```

The following directory structure for compliance is typical. You can specify those that match your project.
```
.
└── compliance
    ├── opencontrol.yaml
    ├── certifications
    │   └── FredRAMP-high.yaml
    ├── components
    │   ├── AU_policy
    │   │   └── component.yaml
    │   └── AWS_core
    │       └── component.yaml
    └── standards
        └── FRIST-800-53.yaml

```

## Installing a commit hook 

A commit hook will run the linter before checkin and prevent checkin of unlinted 
code.

```cassandraql
# Append the pre-comit hook using a here document

tee -a .git/hooks/pre-commit <<EOF
#!/bin/sh
# check the validity of OpenControl files
opencontrol-linter
EOF

# Ensure the hook is executable

chmod 755 .git/hooks/pre-commit

```

## Development

Clone this repo
```
git clone https://github.com/corbaltcode/opencontrol-linter.git

```
Install Dependencies
```
bundle install
```

To run tests:
```
rake spec
```

## Compatibility

Open Control Linter supports the following Open Control schemas:

- Component: (all v1.0 through v3.1)
- Standard: (all v1.0 through v1.0)
- Certification: (all v1.0 through v1.0)

## Related

https://open-control.org/

https://github.com/opencontrol

## Team

Here's a list of Open Control Linter's core developers:

* [Adrian Kierman](https://github.com/adriankierman)
* James Connor
