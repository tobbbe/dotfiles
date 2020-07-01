## KARABINER UNUSED BACKUP
```
  {
    "description": "Toggle Programs",
    "mmmmmmmmmmmmmmmmmmmmmmmanipulators": [
      {
        "type": "basic",
        "from": {
          "key_code": "1",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "shell_command": "open -a 'Google Chrome.app'"
          }
        ]
      },
      {
        "type": "basic",
        "from": {
          "key_code": "2",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "shell_command": "open -a 'Visual Studio Code.app'"
          }
        ]
      },
      {
        "type": "basic",
        "conditions": [
          {
            "bundle_identifiers": [
              "^com\\.tinyspeck\\.slackmacgap$"
            ],
            "type": "frontmost_application_unless"
          }
        ],
        "from": {
          "key_code": "3",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "shell_command": "open -a 'Slack.app'"
          }
        ]
      },
      {
        "type": "basic",
        "conditions": [
          {
            "bundle_identifiers": [
              "^com\\.tinyspeck\\.slackmacgap$"
            ],
            "type": "frontmost_application_if"
          }
        ],
        "conditionsOVAN": [
          {
            "bundle_identifiers": [
              "^com\\.tinyspeck\\.slackmacgap$"
            ],
            "type": "frontmost_application_unless"
          }
        ],
        "from": {
          "key_code": "3",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "key_code": "h",
            "modifiers": [
              "left_command"
            ]
          }
        ]
      },
      {
        "type": "basic",
        "conditions": [
          {
            "bundle_identifiers": [
              "^cc\\.buechele\\.Goofy$"
            ],
            "type": "frontmost_application_unless"
          }
        ],
        "from": {
          "key_code": "4",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "shell_command": "open -a 'Goofy.app'"
          }
        ]
      },
      {
        "type": "basic",
        "conditions": [
          {
            "bundle_identifiers": [
              "^cc\\.buechele\\.Goofy$"
            ],
            "type": "frontmost_application_if"
          }
        ],
        "from": {
          "key_code": "4",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "key_code": "h",
            "modifiers": [
              "left_command"
            ]
          }
        ]
      },
      {
        "type": "basic",
        "from": {
          "key_code": "5",
          "modifiers": {
            "mandatory": [
              "left_command"
            ]
          }
        },
        "to": [
          {
            "shell_command": "open -a 'Finder.app'"
          }
        ]
      }
    ]
  },

  {
    "description": "left_shift to alfred",
    "mmmmmmanipulators": [
      {
        "from": {
          "key_code": "left_shift",
          "modifiers": {
            "optional": ["any"]
          }
        },
        "to": [
          {
              "key_code": "left_shift",
              "lazy": true
          }
        ],
        "to_if_alone": [
          {
            "key_code": "spacebar",
            "modifiers": [
              "left_command"
            ]
          }
        ],
        "type": "basic"
      }
    ]
  },
```