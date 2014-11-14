###
### node.source
###

{% set node = pillar.get('node', {}) -%}
{% set version = node.get('version', '0.10.33') -%}

{% set os = salt['grains.get']('os', None) %}
{% set os_family = salt['grains.get']('os_family', None) %}

## Get nodejs from GitHub
get-node:
  pkg.installed:
    - names:
      - git
  git.latest:
    - name: https://github.com/joyent/node.git
    - rev: v{{ version }}-release
    - target: /usr/local/src/node
    - user: root
    - require:
      - pkg: get-node

## Compile install
{% if os_family == 'RedHat' %}
make-node:
  pkg.installed:
    - names:
      - gcc
      - gcc-c++
      - make
  cmd.wait:
    - cwd: /usr/local/src/node
    - names:
      - ./configure
      - make
      - make install
    - watch:
      - git: get-node
    - require:
      - pkg: make-node
{% elif os_family == 'FreeBSD' %}
make-node:
  pkg.installed:
    - names:
      - gcc
      - gmake
  file.symlink:
    - name: /usr/bin/g++
    - target: /usr/local/bin/g++48
    - user: root
    - require:
      - pkg: make-node
  cmd.wait:
    - cwd: /usr/local/src/node
    - names:
      - python2 ./configure
      - gmake
      - gmake install
    - watch:
      - git: get-node
    - require:
      - pkg: make-node
{% endif %}
