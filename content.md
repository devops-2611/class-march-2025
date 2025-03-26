
## Arguments and Blocks

The Terraform language syntax is built around two key syntax constructs:
arguments and blocks.

### Arguments

An _argument_ assigns a value to a particular name:

```hcl
image_id = "abc123"
```

The identifier before the equals sign is the _argument name_, and the expression
after the equals sign is the argument's value.

### Blocks

A _block_ is a container for other content:

```hcl
resource "aws_instance" "example" {
  ami = "abc123"

  network_interface {
    # ...
  }
}
```

A block has a _type_ (`resource` in this example). Each block type defines
how many _labels_ must follow the type keyword. The `resource` block type
expects two labels, which are `aws_instance` and `example` in the example above.
The `aws_instance` label is specific to the AWS provider. It specifies the `resource` type that Terraform provisions when you apply the configuration. The second label is an arbitrary name that you can add to the particular instance of the resource. You can create multiple instances of the same block type and differentiate them by giving each instance a unique name. In this example, the Terraform configuration author assigned the `example` label to this instance of the `aws_instance` resource. 
A particular block type may have any number of required labels, or it may
require none as with the nested `network_interface` block type.

After the block type keyword and any labels, the block _body_ is delimited
by the `{` and `}` characters. Within the block body, further arguments
and blocks may be nested, creating a hierarchy of blocks and their associated
arguments.

The Terraform language uses a limited number of _top-level block types,_ which
are blocks that can appear outside of any other block in a configuration file.
Most of Terraform's features (including resources, input variables, output
values, data sources, etc.) are implemented as top-level blocks.

## Identifiers

Argument names, block type names, and the names of most Terraform-specific
constructs like resources, input variables, etc. are all _identifiers_.

Identifiers can contain letters, digits, underscores (`_`), and hyphens (`-`).
The first character of an identifier must not be a digit, to avoid ambiguity
with literal numbers.

For complete identifier rules, Terraform implements
[the Unicode identifier syntax](http://unicode.org/reports/tr31/), extended to
include the ASCII hyphen character `-`.

## Comments

The Terraform language supports three different syntaxes for comments:

* `#` begins a single-line comment, ending at the end of the line.
* `//` also begins a single-line comment, as an alternative to `#`.
* `/*` and `*/` are start and end delimiters for a comment that might span
  over multiple lines.

The `#` single-line comment style is the default comment style and should be
used in most cases. Automatic configuration formatting tools may automatically
transform `//` comments into `#` comments, since the double-slash style is
not idiomatic.

## Character Encoding and Line Endings

Terraform configuration files must always be UTF-8 encoded. While the
delimiters of the language are all ASCII characters, Terraform accepts
non-ASCII characters in identifiers, comments, and string values.

Terraform accepts configuration files with either Unix-style line endings
(LF only) or Windows-style line endings (CR then LF), but the idiomatic style
is to use the Unix convention, and so automatic configuration formatting tools
may automatically transform CRLF endings to LF.




# Resources

> **Hands-on:** Try the [Terraform: Get Started](/terraform/tutorials/aws-get-started?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorials.

_Resources_ are the most important element in the Terraform language.
Each resource block describes one or more infrastructure objects, such
as virtual networks, compute instances, or higher-level components such
as DNS records.

- [Resource Blocks](/terraform/language/resources/syntax) documents
  the syntax for declaring resources.

- [Resource Behavior](/terraform/language/resources/behavior) explains in
  more detail how Terraform handles resource declarations when applying a
  configuration.

- The Meta-Arguments section documents special arguments that can be used with
  every resource type, including
  [`depends_on`](/terraform/language/meta-arguments/depends_on),
  [`count`](/terraform/language/meta-arguments/count),
  [`for_each`](/terraform/language/meta-arguments/for_each),
  [`provider`](/terraform/language/meta-arguments/resource-provider),
  and [`lifecycle`](/terraform/language/meta-arguments/lifecycle).

- [Provisioners](/terraform/language/resources/provisioners/syntax)
  documents configuring post-creation actions for a resource using the
  `provisioner` and `connection` blocks. Since provisioners are non-declarative
  and potentially unpredictable, we strongly recommend that you treat them as a
  last resort.
