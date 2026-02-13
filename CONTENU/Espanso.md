```
espanso path
```

Config: C:\Users\Shadow\AppData\Roaming\espanso
Packages: C:\Users\Shadow\AppData\Roaming\espanso\match\packages
Runtime: C:\Users\Shadow\AppData\Local\espanso

After a fresh installation, the `$CONFIG` directory should be structured as follows:

```
$CONFIG/  config/    default.yml  match/    base.yml
```

Copy

As you can see, there are two sub-folders, `config` and `match`, which in turn contain two files, `default.yml` and `base.yml` respectively. Each of them serves a specific purpose:

- **The files contained in the `match` directory define _WHAT_ Espanso should do.** In other words, this is where you should specify all the custom snippets and actions (aka Matches). The `match/base.yml` file is where you might want to start adding your matches, as shown in the following sections. As the number of snippets grows, you might want to _split_ your matches over multiple files to make it easier to manage. For example, you might create the `match/emails.yml` file with the snippets you use while writing emails. You can learn all about matches in the [Matches section](https://espanso.org/docs/matches/basics/).
    
- **The files contained in the `config` directory define _HOW_ Espanso should perform its expansions.** In other words, this is were you should specify all Espanso's parameters and options. The `config/default.yml` file defines the options that will be applied to _all applications by default_, unless an _app-specific configuration_ is present for the current app. For example, you might want to enable emoji snippets for all apps in the `config/default.yml` file, but disable them when using Slack in the `config/slack.yml` file. You can learn all about configurations in the [Configuration section](https://espanso.org/docs/configuration/basics/).
    

All these files are defined using the widely popular [YAML](https://en.wikipedia.org/wiki/YAML) format.
YAML (/ˈjæməl/ ⓘ; see § History and name) is a human-readable data serialization language. It is commonly used for configuration files and in applications where data is being stored or transmitted. YAML targets many of the same communications applications as Extensible Markup Language (XML) but has a minimal syntax that intentionally differs from Standard Generalized Markup Language (SGML).[3] It uses Python-style indentation to indicate nesting[3] and does not require quotes around most string values (it also supports JSON style […] and {…} mixed in the same file).[4]
## Creating your own Matches[​](https://espanso.org/docs/get-started/#creating-your-own-matches "Direct link to heading")

That's enough theory for now, let's start with some action! Let's say you write a lot of emails and you're tired of writing the greetings at the end, so you decide to speed up the process.

We will configure Espanso so that every time you type `:br`, it will be expanded to:

```
Best Regards,Jon Snow
```

Copy

By now you should know that we need to **define a Match**.

With your favourite text editor, open the `$CONFIG/match/base.yml` file, introduced previously in the [Configuration](https://espanso.org/docs/get-started/#configuration) section. You should see something like:

$CONFIG/match/base.yml

```
# espanso match file# For a complete introduction, visit the official docs at: https://espanso.org/docs/# You can use this file to define the base matches (aka snippets)# that will be available in every application when using espanso.# Matches are substitution rules: when you type the "trigger" string# it gets replaced by the "replace" string.matches:  # Simple text replacement  - trigger: ":espanso"    replace: "Hi there!"...
```

Copy

We need to define a new Match, so in the `matches:` section, add the following code:

```
  - trigger: ":br"    replace: "Best Regards,\nJon Snow"
```

Copy

##### Important

**Make sure to include the indentation**, otherwise it won't be valid YAML syntax. Also, prefer spaces to tabs if possible.

You should get something like:

$CONFIG/match/base.yml

```
# espanso match file# For a complete introduction, visit the official docs at: https://espanso.org/docs/# You can use this file to define the base matches (aka snippets)# that will be available in every application when using espanso.# Matches are substitution rules: when you type the "trigger" string# it gets replaced by the "replace" string.matches:  # Simple text replacement  - trigger: ":espanso"    replace: "Hi there!"  - trigger: ":br"    replace: "Best Regards,\nJon Snow"...
```

Copy

All right! After saving the file, Espanso should automatically detect the change and reload your configuration.

Now try to type `:br` anywhere. If you did everything correctly, you should see `Best Regards` appear!

##### Quick Editing

If you are comfortable using the terminal to edit your configurations, you can also run this command:

```
espanso edit
```

Copy

which spawns an instance of the system-default text editor.

By default it uses Nano on Unix and Notepad on Windows, but you can customize it as you like. Take a look at [Editing CLI shortcut](https://espanso.org/docs/configuration/basics/#editing-cli-shortcut) for more information.

## Understanding Packages[​](https://espanso.org/docs/get-started/#understanding-packages "Direct link to heading")

Custom matches are great, but sometimes it can be tedious to define them for every common operation, especially when you want to **share them with other people**.

Espanso offers an easy way to **share and reuse matches** with other people, **packages**. In fact, they are so important that Espanso includes a **built-in package manager** and a **store**, the [Espanso Hub](https://hub.espanso.org/).

If you are lucky enough, someone might have already written a **package** to include the matches you need! Otherwise, you can create a package and publish it on the Hub, for more information check out the [Packages](https://espanso.org/docs/packages/basics/) documentation.

### Installing a Package[​](https://espanso.org/docs/get-started/#installing-a-package "Direct link to heading")

Let's say you want to **add some emojis** to Espanso, such that when you type `:ok` it gets expanded to 👍.

A solution would be to install the [Basic Emojis](https://hub.espanso.org/basic-emojis) package from the [Espanso Hub](https://hub.espanso.org/) store. Open a terminal and type:

```
espanso install basic-emojis
```

Copy

Espanso should detect the change and reload the configuration automatically. If you now type `:ook` into any text field, you should see 👍👍👍👍 appear!

##### Troubleshooting

Espanso should automatically reload the configuration after you install a package. If that doesn't happen, please open a terminal and run:

```
espanso restart
```

Copy

## Useful shortcuts[​](https://espanso.org/docs/get-started/#useful-shortcuts "Direct link to heading")

Let's conclude this introduction with the most important shortcuts Espanso offers, the **search-bar shortcut**, the **backspace undo** and the **toggle shortcut**.

### Search-bar[​](https://espanso.org/docs/get-started/#search-bar "Direct link to heading")

Espanso comes with a powerful _Search-bar_ to quickly find and insert your matches. You can open the search bar in several ways:

- Press `ALT+SPACE` (Option+Space on macOS).
- Click on the taskbar status icon and select "Open Search bar" (not available on Linux).
- [Customize the search trigger](https://espanso.org/docs/configuration/options/#customizing-the-search-trigger) and type it anywhere.

Several Espanso control and report commands may be displayed by typing ">" at the beginning of the Search Bar.

### Backspace Undo[​](https://espanso.org/docs/get-started/#backspace-undo "Direct link to heading")

Sometimes you might accidentally trigger an expansion. If you immediately press the `BACKSPACE` key after the expansion, the action is reverted and the trigger recovered.

You can also disable this behavior by adding the following line on your `config/default.yml` file:

```
undo_backspace: false
```

Copy

> Note that backspace undo might not be always available.

### Toggle Key[​](https://espanso.org/docs/get-started/#toggle-key "Direct link to heading")

Sometimes you might want to **disable Espanso to avoid an unwanted expansion**. This can be accomplished in many ways, including the icon menu:

![Icon Menu](https://espanso.org/assets/images/icon-menu-505f49d8edc22ab37581ea1feaa57566.png)

If you want a quicker way to toggle Espanso ON and OFF, you can also [Customize the Toggle Key](https://espanso.org/docs/configuration/options/#customizing-the-toggle-key).

## Editors[​](https://espanso.org/docs/get-started/#editors "Direct link to heading")

Espanso's configuration and match files can be written in any text editor and most users will start with Notepad or whatever they have to hand. However, a few warrant particular mention.

### EspansoEdit[​](https://espanso.org/docs/get-started/#espansoedit "Direct link to heading")

[EspansoEdit](https://espanso.org/docs/tools/#espansoedit) is a dedicated freeware editor and utility for Espanso with many useful features.

### VSCode (VSCodium)[​](https://espanso.org/docs/get-started/#vscode-vscodium "Direct link to heading")

Microsoft’s [VSCode](https://code.visualstudio.com/) and the open-source version, [VSCodium](https://vscodium.com/), are sohisticated editors with a steep learning curve for new users, but both can use **schemas**. Schemas efficiently highlight coding errors during typing, avoiding the wait for Espanso to fail with errors when an incorrectly written file is saved!

![Schema output](https://espanso.org/assets/images/schema-371a87fbd514795affb887e0e069236d.png)

To use schemas, install the Red Hat YAML [extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), and add the following lines at the top of all your `espanso/config`:

```
# yaml-language-server: $schema=https://raw.githubusercontent.com/espanso/espanso/dev/schemas/config.schema.json
```

Copy

and `espanso/match`:

```
# yaml-language-server: $schema=https://raw.githubusercontent.com/espanso/espanso/dev/schemas/match.schema.json
```

Copy

files.

User experience suggests that the `clipboard` backend works best in VSCode/VSCodium. See the app-specific configuration example at the end of [this](https://espanso.org/docs/configuration/app-specific-configurations/#filters) section.

### Neovim[​](https://espanso.org/docs/get-started/#neovim "Direct link to heading")

[Neovim](https://neovim.io/) can also be configured to use the schemas:

You can install the `yaml-language-server` (`yamlls`) via [`mason`](https://github.com/williamboman/mason.nvim) and `lspconfig`. Ensure you keep the `# yaml-language-server: $schema=https...` link in order to use the schema!


## alt

# [6 Best Espanso Alternatives to Save Time in 2026](https://blaze.today/blog/espanso-alternatives/)
For anyone who loves to get things done quickly on their computer, finding the right shortcuts can be like discovering a hidden treasure.

Text expanders are some of the best-kept productivity secrets. They're like magic helpers for anyone who types a lot, whether you're writing emails, coding, or just jotting down notes.

>
>
> Instead of typing the same long phrases over and over, text expanders let you type just a few letters and poof! The whole phrase appears.
>
>

But with so many options out there, picking the best one can be tough. If you're on the hunt for a tool that makes typing faster and easier, you're in the right place.

In this article, we'll list the 6 best Espanso alternatives to help you save time in 2026.

What Is Espanso?
----------

![](https://blaze.today/images/posts/espanso-new.png)

[Espanso](https://espanso.org/) is a noteworthy contender in the realm of text expansion tools, designed to elevate the typing experience by replacing specified keystrokes with full text snippets.

It operates on the principle of efficiency, allowing users to save precious time and avoid repetitive strain.

### Espanso Features ###

Espanso is a bit like a Swiss Army knife for typing; it's packed with features that make it super versatile and helpful. Here's a quick look at what it can do:

* **Text Snippets**: Automatically replace short abbreviations with longer pieces of text.

* **Shell Commands Execution**: Run commands in your shell directly from your text expander.

* **Emojis Support**: Quickly insert emojis by typing shortcuts.

* **Forms**: Use forms to insert text with variable parts that you can fill in on the fly.

These features make Espanso more than just a text expander. It's a useful tool that can adapt to various tasks, helping you work smarter, not harder.

### Espanso Pricing ###

One of Espanso's strong suits is its pricing model. As an open-source project, it is freely available to the public, which makes it an attractive option for individuals and organizations looking to enhance productivity without incurring additional costs.

This accessibility has made Espanso a popular choice among the text expansion community.

6 Best Espanso Alternatives
----------

While Espanso offers a robust set of features, there are several other tools in the market that cater to different preferences and requirements.

Here's a look at the 7 best Espanso alternatives:

### 1. Text Blaze ###

![](https://blaze.today/images/posts/forms-loop.gif)

First up on our list of the best free Espanso alternatives is [Text Blaze](https://blaze.today/textexpander).

Text Blaze is a text expander that helps you boost your productivity through keyboard shortcuts that you can use to create templates that can be used anywhere you work.

**Text Blaze Features**

* Text Blaze helps people automate repetitive typing with keyboard shortcuts.

* Text Blaze is **free forever**!

* Text Blaze **works on any site or app** via our [Chrome Extension](https://chromewebstore.google.com/detail/text-blaze-templates-and/idgadaccgipmpannjkmfddolnnhmeklj), [Windows app](https://blaze.today/windows/), and [Mac app](https://blaze.today/mac/)!

* Placeholders, business rules, calculations, and more help you create **powerful templates for any situation**!

* Use **AI to create templates & draft emails** anywhere you work!

* Text Blaze is the **#1 rated productivity extension** on the Chrome Web Store with a **4.9 rating & 1000+ reviews**!

**Text Blaze Pricing**

* **Text Blaze is 100% free**: Say goodbye to annoying license purchases or limited trials! You can use Text Blaze expand text and save time without ever needing to break out your wallet.

“Now that I use Text Blaze, I never want to go back to doing things the way I used to.”

**Yu'Vonne James** — Assistant Principal

Want to save hours of repetitive typing for free?

Join 700,000+ who are using Text Blaze templates.

### 2. PhraseExpress ###

![](https://blaze.today/images/posts/phraseexpress.jpg)

[PhraseExpress](https://www.phraseexpress.com/) is an autotext software that has an emphasis on templates that you can use multiple times to save time.

**PhraseExpress Features**

* Cloud synchronization lets you save phrases online.
* Phrases can be in multiple languages.
* The document-generator helps you create templates for any situation.
* No subscriptions.

**PhraseExpress Pricing**

* Standard license for $75.59 USD per user.

### 3. aText ###

![](https://blaze.today/images/posts/aText.jpeg)

[aText](https://www.trankynam.com/atext/) is a text automation software that helps you streamline the typing process through text snippets.

**aText Features**

* Works on Windows and macOS.
* Cloud sync allows you to sync data across shared networks.
* Built-in snippets that can be used for coding (HTML and JavaScript).

**aText Pricing**

* 1 year license $4.99 per user.

### 4. TextExpander ###

![](https://blaze.today/images/posts/text-expander.png)

[TextExpander](https://textexpander.com/) is another option that helps you automate typing using text snippets.

**TextExpander Features**

* TextExpander offers plans for both individuals and teams.
* There are different plans for different-sized teams.
* You can use text snippets to automate your typing.

**TextExpander Pricing**

* Free trial, then individual plan for $4.16 USD per user per month.

Want to save hours of repetitive typing for free?

Join 700,000+ who are using Text Blaze templates.

### 5. AutoHotkey ###

![](https://blaze.today/images/posts/autohotkey.png)

[AutoHotkey](https://www.autohotkey.com/) is an automation scripting language that is used by developers to improve typing.

**AutoHotkey Features**

* Great tool for developers because of its developed scripting language.
* Open-sourced and hosted on GitHub.
* Many advanced features for complex text expansion.

**AutoHotkey Pricing**

### 6. Magical ###

![](https://blaze.today/images/posts/magical.png)

[Magical](https://www.getmagical.com/) stands out for its simplicity and ease of use, particularly for those who primarily work within web browsers.

It integrates seamlessly with Chrome, allowing users to create and use snippets without leaving their browser window.

**Magical Features**

* Automate text with keyboard shortcuts.
* Use AI to generate templates.
* Fill forms and automate data transfer.
* Save time with template editing from anywhere.

**Magical Pricing**

* Free plan & core plan for $6.50 /month/user.

Want to save hours of repetitive typing for free?

Join 700,000+ who are using Text Blaze templates.

Which Text Expander Is Your Favorite?
----------

There are a lot of options regarding text expanders and ways to boost your typing efficiency. We hope this article gave you an idea of which text expander is best for you.

To recap, our suggestion for the best free Espanso alternative is [Text Blaze](https://blaze.today/textexpander). Text Blaze is the best free text expander that works on any website!