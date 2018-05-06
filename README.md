# linux admin game
> Learn linux while playing sysadmin missions!

[![Build Status](https://travis-ci.org/6uhrmittag/linux-admin-game.svg?branch=master)](https://travis-ci.org/6uhrmittag/linux-admin-game)

The Linux admin game helps you to learn linux admin tasks like installing a webserver or updating the system.
You'll get missions and tasks to solve and hints on how to solve the mission. 

## Installation

Requirements:
- Ubuntu
- sudo
- fresh VM

Note: Please use this game on a fresh VM, that you can delete later, only. Since you'll modify the system.

The setup adds the alias "admingame" to your .bash_profile to let you run the game with just "admingame"
```sh
git clone https://github.com/6uhrmittag/linux-admin-game.git
cd linux-admin-game
sudo ./setup.sh
admingame
```

## Usage
```
 Linux admin game

 Start the game
    start   (list, select and start mission)

 In-game control
    tasks   (show tasks)
    end     (end game, show restult)

 Tutor mode:
 Guides you through your mission. Checks every minute if you solved a task and shows hints.
    tutor   (start tutor)
```

Select your mission:

![Select your mission](./documentation/screenshot_input.png)

View your tasks:

![View your tasks](./documentation/screenshot_tasks.png)

## Interactive tutor mode
Starts a background tutor that checks your tasks and shows hints while playing.
![Get your result](./documentation/screenshot_result.png)


## Development setup

To run a test for all missions run `./game.sh testing`. 
Run this on a fresh VM/CI only. Testing mode installs/executes all mission tasks.

generate documentation:
```sh
make doku
```

## Meta

Marvin Heimbrodt – [@6uhrmittag](https://twitter.com/6uhrmittag) – marvin@6uhrmittag.de

(***TODO***) Distributed under the XYZ license. See ``LICENSE`` for more information.

[https://slashlog.de/](slashlog.de)

## Contributing

1. Fork it (<https://github.com/6uhrmittag/linux-admin-tutor/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

## Add missions

1. Fork it (<https://github.com/6uhrmittag/linux-admin-tutor/fork>)
2. Create your mission branch (`git checkout -b mission/fooBar`)
3. Add your mission using the template
4. Please make sure all tasks are solvable! (Travis should be able to check the "test" sections)
5. Commit your changes (`git commit -am 'Add some fooBar'`)
6. Push to the branch (`git push origin mission/fooBar`)
7. Create a new Pull Request

## Acknowledgments

* [Lynis - Security auditing tool](https://github.com/CISOfy/lynis) - inspired the game mode
* [shdoc - Documentation generator for shell scripts](https://github.com/reconquest/shdoc) - used for documentation