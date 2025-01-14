IO Reader GENerator
===================

## Description

*Iorgen* is a multi languages code generator to parse a predefined input
template. The user writes a YAML describing the input, and *Iorgen* will
generate the code to read this input from stdin, in all supported languages.

The list of currently supported languages is: C, C++, C#, D, Go, Haskell, Java,
Javascript, Julia, Lua, Ocaml, Pascal, Perl, PHP, Prolog, Python, Ruby, Rust,
Scheme. A Markdown description of the input in English and French can also be
generated.

## Installation

You can install `iorgen` in a virtual environment like this:

```
git clone git@gitlab.com:prologin/tech/tools/iorgen.git
cd iorgen
python3 -m venv .venv
source .venv/bin/activate
pip3 install poetry
poetry install
```

You can then run it with the `iorgen` command.

### Testing the languages

You should be able to trust that *Iorgen* will generate valid files. But if you
want to be sure that those files are valid, and want to generate the test suite
for instance, you will have to install lots of compilers.

The complete dependencies for Archlinux are:
```shell
pacman -S --needed python-yaml fpc gambit-c gcc gdc ghc go jdk-openjdk julia \
    lua mono nodejs ocaml perl php ruby rust swi-prolog
```

For Debian based distros (tested on Debian 10, Ubuntu 18.04 and 20.04):
```shell
sudo apt install python3-yaml default-jdk-headless fp-compiler gambc gcc gdc \
    ghc golang julia lua5.3 mono-mcs nodejs ocaml-nox perl php-cli ruby rustc \
    swi-prolog-nox
```

The compilers must not be too old. For instance for Ocaml you need at least
version 4.06, which is more recent that the default version in Ubuntu 18.04
and Debian 10.

## Usage

Make sure python (version 3.7 and above) and python-yaml are installed on your
computer and run `python3 -m iorgen gen-stubs input.yaml`. This will generate
all languages parsers in a `skeleton` folder, and a `input-subject-io-stub.md`
describing the input (in French by default).

*Iorgen* functionalities are separated in the following subcommands:

### `gen-stubs` (Stubs generation)

This subcommand allows you to generate languages parsers (skeletons) and a
markdown subject stub.

You are able to generate these for a single YAML input file or multiple files at once.

By default, the languages parsers will be generated in the `skeleton` directory. However, you can change the output directory with the `--output_dir` option.

You can also chose to generate all files in the parent directory of the YAML input file with the `--same_dir` flag, by default it will generate the files in the current working directory.
Note that the generated markdown stub will be named `subject-io-stub.md` when using `--same_dir` flag, otherwise it will be prefixed with the YAML input file name like this: `<prefix>-subject-io-stub.md`.

#### Examples

1. Generate problem stubs in the current working directory

```shell
iorgen gen-stubs 42.yaml
```

2. Generate multiple problem stubs at once

```shell
iorgen gen-stubs 42/42.iorgen loueur/loueur.yaml
```

You can also use your shell globs!

```shell
iorgen gen-stubs **/*.yaml
```

3. Generate all stubs next to their YAML input file

```shell
iorgen gen-stubs --same_dir **/*.yaml
```

### `gen-input` (Random input generation)

This subcommand allows you to generate a valid raw input based on your YAML input file.

You can specify a value, the minimum value or the maximum value of a variable
for the generated raw input with the `--specify` option.
`NAME VALUE` will set the value. `NAME_max VALUE` the maximum value and
`NAME_min VALUE` the minimum value.

You can also treat raw input as in performance mode by using the `--perf_mode` flag.
The performance mode is a mode where the constraints are different, usually the
integers are bigger.

#### Example

```shell
iorgen gen-input -s N_max 10 i 42 -- example.yaml
```

### `validate` (Raw input file validation)

This subcommand allows you to check raw input files against a YAML input file.

You can also check raw inputs made generated for performance tests by using the `--perf_mode` flag.

1. Validate a single file

```shell
iorgen validate 42.iorgen test/01.in
```

2. Validate multiple files

```shell
iorgen validate 42.iorgen test/01.in test/02.in test/03.in
```

or using globs

```shell
iorgen validate 42.iorgen 'test/*.in'
```

or using shell globs

```shell
iorgen validate 42.iorgen test/*.in
```

### `run` (Parsers check)

This subcommand allows you to check that the parsers generated by iorgen
properly parse and print the input they are fed with.

You may want to use the `--languages` option to specify the list of tested
languages if you don't have all of them installed. See [this section](#testing-the-languages)
to know how to test against all languages.

#### Example

```shell
iorgen run 42.iorgen test/test01.in
```

## Input format

### Types

*Iorgen* can use the following types:

- **Integer**: the default integer type for the language
- **Float**: a double precision floating-point number, often called "double" in
  languages; see below for more details about float support
- **Char**: can be either a byte, or a string depending of the language
- **String**: a string with a given maximum size
- **List**: an array, list, vector… of a given size, containing one of the
  *Iorgen* supported types
- **Struct**: a C like struct, or a map which have strings as keys; each field
  can have any of *Iorgen* supported types (except the exact same struct)

#### Float support

*Iorgen* supports floating-point numbers, but beware they are not as easy to
use as integers. Here are the constrains when using floats:

- A maximum of 15 digts can be used to write a float (in decimal notation).
  This means that, with the minus and dot sign, a float can take up to 17
  characters. Here are some example values: `123456789012345`,
  `12345.6789012345`, `0.00123456789012`, but of course the number can take
  less digits, like `3.5` or `0.03`.
- When writing the floats in the input that will be fed in STDIN, a unique
  format should be respected, and that is the `".15g"` format from C.
  Concretly, combined with the first constraint, this means that any number
  that starts with `0.0000` (or `-0.0000`), should be written in scientific
  notation instead. For example, `1e-5`, `3.924e-07`. Also, no trailing dot, no
  trailing 0, and no unnecessary 0 before the number, except in the exponent if
  it smaller than 2 digits. Conforming to the `".15g"` C format in necessary
  for _Iorgen_ to be able to test that the parser are working properly (the
  `run` command).

### Format

The input is described in [YAML](http://yaml.org/), and must have the following
format:

- A `"function_name"` field, containing the name of the generated function
- A `"subject"` field, containing a string (can be several paragraphs)
  describing what the input is about (will no be used in generated code)
- An `"ouput"` field, containing a string (can be several paragraphs)
  describing what the end user have to do with the parsed input
- An `"input"` field, containing a list of variables. Each variable is a map
  with the following fields:
    - A `"type"` field, containing a string (see the type syntax below)
    - A `"name"` field, containing a string: the variable’s name
    - A `"comment"` field, containing a string: a description of the variable
    - An optional `"min"` field, if the variable is a integer, a float, or a
      list (or list or list, or list of list of list, etc) of integers or
      floats. This will be the minimal value possible for this variable. This
      is used in the Markdown generator to show the constraints, and in some
      langages generators to check if the size of a list or a string is
      garantied to be not null. The `"min"` field can either be an integer, a
      float (if the variable is of type float), or a variable name.
    - An optional `"max"` field (similar to the `"min"` one).
    - An optional `"min_perf"` field: like the `"min"` one, but only used in
      the case of _performance_ cases, often meaning that the variable will
      have a very big value.
    - An optional `"max_perf"` field (similar to the `"min_perf"` one).
    - An optional `"choices"` field, if the variable is an integer, a float or
      a char, or a list (or list of list, etc) of integers, floats or chars
      (for this definition a string is considered as a list of chars).
      `"choices"` is a list of values possible for this integer, float or char.
      If this list is not empty, then the `"min"` fields and similar fields
      will be ignored.
    - An optional `"format"` field, containing a string; see the [manual
      formatting](#manual-formatting) section to know more.
- An optional `"structs"` field, if your input uses structs, a list of structs.
  Each struct is a map with the following fields:
    - A `"name"` field, containing a string: the struct’s name
    - A `"comment"` field, containing a string: a description of the struct
    - A `"fields"` field, containing a list of the struct’s fields (same syntax
      as `"input"`)

### Syntax

Any `"name"` field (or `"function_name"`) can hold any alphanumic character or
spaces, but must start with a letter, and can not have trailing whitespaces.
You do not have to worry about the name beeing a language’s keyword: it will
automatically be modified if that is the case, usually by adding a trailing
underscore.

A `"comment"` field can hold any character other than a newline. For now,
strings that end comments in some languages, such as `*/` should be avoided. A
protection against this will be added in a later version.

A `"type"` field must have one of the following format `int`, `float`, `char`,
`str(size)`, `List[type](size)`, `@structname`. You must replace `size`, `type`
and `structname` following this guidelines:

- `size` can be either a number, or a variable name. If it is a variable name,
  it must be a toplevel one (i.e. in the `"input"` list), and must have been
  declared before use. One exception: you can use a struct with two fields:
  one integer, and a other a type whose size is the first field. For strings,
  the given size, in the maximum size the string will have, but it could be
  less.
- `type` can be any valid type, even an other list
- `structname` is the name of a struct, as declared in the `"name"` field of
  `"structs"`

#### Manual formatting

*Iorgen* is supposed to choose how the input should be. For instance, each
integer variable stands on its own line. Lists of integers however put them
all on the same line. There are reasons for this: one variable per line is
easier to parse on most languages; putting integers on the same line keeps
inputs shorter. Anyway, even if you don't agree with those choices, you should
not really care and just go with how *Iorgen* does things.

If you have the choice, don't try to change the defaults, just go with the
flow: it is how *Iorgen* was meant to work and it is well tested with those
defaults. However if your input is already set is stone and you can not change
it, *Iorgen* provides a few options to tweak the input layout.

- You can have several integers variables on the same line. All variables must
  be integers, and follow each other in the `input` list. For every of the
  variables but the last one put the `"format": no_endline` field.
- You can have a list of integers with one entry per line, instead of having
  all the integers on the same line. This currently works for a simple
  `List[int]`, not for any nested type. Use the `"format": force_newlines`
  field.

### Example

```yaml
function_name: example
subject: This input is an example for Iorgen's README
structs:
    - name: a struct
      comment: A struct for the example
      fields:
          - type: int
            name: integer
            comment: an integer
            choices: [-4, 42, 1337]
          - type: char
            name: character
            comment: a char
            choices: [a, b, c]
input:
    - type: int
      name: N
      comment: a number, used as a size
      min: 1
      max: 10
      max_perf: 10000
    - type: List[@a struct](N)
      name: list
      comment: a list of structs
output: In a real life scenario, you will describe here what you want the end
    user to do with this generated code
```

If you want to generate the C code for parsing this kind of input, run
`python3 -m iorgen gen-stubs -l c example.yaml`, and you will get the following
`skeleton/example.c`:

```c
#include <stdio.h>
#include <stdlib.h>

/// A struct for the example
struct a_struct {
    int integer; ///< an integer
    char character; ///< a char
};

/// \param n a number, used as a size
/// \param list a list of structs
void example(int n, struct a_struct* list) {
    /* TODO In a real life scenario, you will describe here what you want the
    end user to do with this generated code */
}

int main() {
    int n;
    scanf("%d", &n);
    struct a_struct* list = (struct a_struct*)malloc(n * sizeof(struct a_struct));
    for (int i = 0; i < n; ++i) {
        scanf("%d %c", &list[i].integer, &list[i].character);
    }
    example(n, list);

    return 0;
}
```

You can see every other thing that _Iorgen_ can generate in the
[test samples](test/samples/example/); you can find parsers for lots of
languages, and also a [generated description of the input in
Markdown](test/samples/example/example.en.md).
