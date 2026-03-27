# h1 Heading

## h2 Heading

### h3 Heading

#### h4 Heading

##### h5 Heading

###### h6 Heading

## Horizontal Rules

___

## Typographic replacements

test.. test... test..... test?..... test!....

!!!!!! ???? ,,  -- ---

"Smartypants, double quotes" and 'single quotes'

## Emphasis

Example **This is bold text**

Example *This is italic text*

~~Strikethrough~~

## Blockquotes

> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.

## Lists

Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  + Marker character change forces new list start:
    + Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    + Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa

4. You can use sequential numbers...
5. ...or keep all the numbers as `1.`

Start numbering with offset:

1. foo
1. bar

## Code

Inline `code`

Indented code

```txt
    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code
```

Block code "fences"

```txt
Sample text here...
```

Syntax highlighting

```dart
const Padding(
      padding: EdgeInsets.only(top: 8),
      child: MarkdownView(page: 'demo'),
    )
```

## Tables

| Option | Description                                                               |
| ------ | ------------------------------------------------------------------------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default.    |
| ext    | extension to be used for dest files.                                      |

Right aligned columns

| Option | Description                                                               |
| ------:| -------------------------------------------------------------------------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default.    |
| ext    | extension to be used for dest files.                                      |

## Links

[link text](http://example.com)

[link with title](http:/example.com "title text!")

Autoconverted link <https://example.com> (enable linkify to see)

### [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.

### [Definition lists](https://github.com/markdown-it/markdown-it-deflist)

Term 1

:   Definition 1
with lazy continuation.

Term 2 with *inline markup*

:   Definition 2

```txt
        { some code, part of Definition 2 }

    Third paragraph of definition 2.
```

*Compact style:*

Term 1
  ~ Definition 1

Term 2
  ~ Definition 2a
  ~ Definition 2b

### [Abbreviations](https://github.com/markdown-it/markdown-it-abbr)

This is HTML abbreviation example.

It converts "HTML", but keep intact partial entries like "xxxHTMLyyy" and so on.

*[HTML]: Hyper Text Markup Language

### [Custom containers](https://github.com/markdown-it/markdown-it-container)

::: warning
*warning message*
:::
