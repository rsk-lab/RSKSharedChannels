<p align="center">
    <img width="652" alt="RSKSharedChannels" src="https://user-images.githubusercontent.com/1182823/38630695-566dbc6a-3dc0-11e8-8bd3-7f67b9b47c7d.png">
</p>

[Slack's shared channels](https://slackhq.com/introducing-shared-channels-where-you-can-work-with-anyone-in-slack-8c5d2a943f57) is a brand new feature that lets two separate workspaces communicate securely in Slack. You can share any channel on your workspace to another team’s workspace - like clients, customers, or contractors you work with regularly.

Unfortunatelly, it is still in [Beta](https://get.slack.help/hc/en-us/articles/115004151183). Workspaces on Slack Enterprise Grid can connect shared channels to other workspaces in their organization, but it’s not possible to create a shared channel with an external workspace at this time.

## Proof of concept

**RSKSharedChannels** allows you with minimal efforts to share any channel on your workspace to another team's workspace.

:white_check_mark: Create a common area between two unique workspaces, so you can find everything you need in one place.

:white_check_mark: Simplify communication, streamline conversations, and gain efficiency.

:white_check_mark: Make information and context easier to find across workspaces.

## Requirements

- Slack 3.1.1
- xCode 9.3

## Setting up the environment

### Setting up Slack bots

  1. Create a bot that will represent another team in your Workspace.
    - Go here: [https://my.slack.com/services/new/bot](https://my.slack.com/services/new/bot)
    - Enter a username for the bot.
    - Click "Add bot integration".
    <p align="center">
        <img width="700" alt="New Bot" src="https://user-images.githubusercontent.com/1182823/38630520-d5a6d62a-3dbf-11e8-9245-e7df170b3b6d.png">
    </p>
  2. Copy the API token that Slack generates and replace a placeholder of `xWorkspaceBotAPITokenString` in [`Environment.swift`](https://github.com/rsk-lab/RSKSharedChannels/blob/master/Sources/RSKSharedChannels/Environment.swift#L38) with the real deal.
      <p align="center">
        <img width="700" alt="Bot API Token" src="https://user-images.githubusercontent.com/1182823/38619493-ed040902-3da4-11e8-8cd0-563a85e52c2b.png">
      </p>
  3. Ask a primary owner or an admin of another team to create a bot that will represent your team in his Workspace and ask him to send you the created API token.
  4. Replace a placeholder of `yWorkspaceBotAPITokenString`  in [`Environment.swift`](https://github.com/rsk-lab/RSKSharedChannels/blob/master/Sources/RSKSharedChannels/Environment.swift#L58) with the real deal.

### Testing locally

  1. Checkout dependencies.
  
        ```sh
        swift package update
        ```
  2. Open Xcode.
  3. Select the `RSKSharedChannels` application executable target and run it (⌘+R).
    <p align="center">
        <img width="700" alt="Application Executable Target" src="https://user-images.githubusercontent.com/1182823/38627468-b423fc42-3db7-11e8-8927-43cd6c6b2e14.png">
    </p>
  4. Head over to Slack. Your bots presence indicators should be filled in.
      <p align="center">
        <img width="240" alt="Bot Presence Indicator" src="https://user-images.githubusercontent.com/1182823/38619962-0d4822c4-3da6-11e8-8d63-d97445dff6ad.png">
      </p>
  5. Invite bots to channels you would like to share. Channel names must match in the workspaces of both teams.

### Deploying to the ☁️ (optional)

  1. If you don’t have an account on Heroku go and [sign up for a free one](https://signup.heroku.com/).
  2. Setup Heroku:
    - Install the Heroku [toolbelt](https://toolbelt.heroku.com/).
    - Log in to Heroku in your terminal:
    
        ```sh
        heroku login
        ```
    
    - Create a new application on Heroku and set a buildpack (use a unique name since Heroku app names are unique):
    
        ```sh
        heroku create --buildpack https://github.com/kylef/heroku-buildpack-swift rsk-shared-channels
        ```
    
    - Set up configuration variables:
      - Add a new configuration variable named `xWorkspaceBotAPITokenString` with the API token of the bot that represents another team in your Workspace.
      
          ```sh
          heroku config:set xWorkspaceBotAPITokenString=xoxb-...RS
          ```
      
      - Add a new configuration variable named `yWorkspaceBotAPITokenString` with the API token of the bot that represents your team in the Workspace of another team.
      
          ```sh
          heroku config:set yWorkspaceBotAPITokenString=xoxb-...GB
          ```
      
    - Set up a Heroku remote (use your unique name here, too):
    
        ```sh
        heroku git:remote -a rsk-shared-channels
        ```
      
    - Push to master:
    
        ```sh
        git push heroku master
        ```
      
      At this point, you’ll see Heroku go through the build process.
      <p align="center">
        <img width="650" alt="Build Process on Heroku" src="https://user-images.githubusercontent.com/1182823/38620713-dc80e9f8-3da7-11e8-9ae2-c25eab9e221f.png">
      </p>
      
    3. Run the app.
    
        ```sh
        heroku run:detached web
        ```
    
    4. Head over to Slack. Your bots presence indicators should be filled in.
        <p align="center">
            <img width="240" alt="Bot Presence Indicator" src="https://user-images.githubusercontent.com/1182823/38619962-0d4822c4-3da6-11e8-8d63-d97445dff6ad.png">
        </p>

### 🎊 You're done! 🎊

Type a message and press the Enter key!

## Contacts

<a href="mailto:hello@rsk-lab.com"><img width="200" alt="Hire R.SK Lab Team" src="https://user-images.githubusercontent.com/1182823/38809722-2d3e6d8c-418d-11e8-9dad-2b1f647c6581.png"></a>

## License

This project is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
