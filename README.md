This is a simple interactive introduction to CoffeeScript.

# System Dependencies

You'll need the following things installed:

- `node` and `npm`
  - `brew install node`
- `coffee`
  - `npm install -g coffee-script`
- `grunt`
  - `npm install -g grunt-cli`

In order to run the `npm install -g` you'll need to `sudo` it or `chown -R` your `/usr/local/share/npm`.

Make sure `/usr/local/share/npm/bin` is in your `PATH` for the rest of the example to work.

# Building

After you have those, install the local node dependencies:

    npm install

Build the static things:

    grunt

And start the server:

    coffee main.coffee --port 3000

# Hacking

If you want to hack on this and your dev setup mirrors mine exactly (meaning you use Chrome, TotalTerminal for transient commands like `hg`, iTerm for long-running things like your server, and Sublime Text), you can do this for instant action:

In Sublime Text, go to *Tools > Build System > New Build System...* and save this:

    {
        "shell_cmd": "grunt magic --no-color"
    }

Then you can hit `⇧⌘B` to type the characters `"^Ccoffee server.coffee\n"` into iTerm, focus Chrome (the most recently active window; if anyone has a better way of doing that let me know) and reload the current tab.

If you're using vim all of this should work the same except you'll need to modify the iTerm script to get the right session. Unless you're using MacVim or something, you animal.
