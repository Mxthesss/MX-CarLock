# MX-CarLock

MX-CarLock is a FiveM script designed to provide a convenient way to lock and unlock cars in your server. It supports the latest version of ESX and utilizes a config file for customization. Please note that this script has a dependency on the ox_lib library.

## Features

- Lock and unlock cars
- Compatibility with the latest version of ESX
- Customizable configuration options

## Prerequisites

Before using MX-CarLock, make sure you have the following prerequisites:

- [FiveM](https://fivem.net/)
- [ESX](https://github.com/ESX-Org/es_extended) (latest version)
- [ox_lib](https://github.com/overextended/ox_lib) (dependency)

## Installation

1. Clone the MX-CarLock repository to your Server:

- git clone https://github.com/Mxthesss/MX-CarLock.git

2. Copy the `MX-CarLock` folder into your FiveM resource directory.

3. Add `ensure MX-CarLock` to your `server.cfg` file.

4. Download and install the latest version of ESX.

5. Install the `ox_lib` library by following the instructions in its repository.

## Configuration

1. Open the `config.lua` file located in the `MX-CarLock` folder.

2. Customize the following options based on your preferences:

- Locale (now support EN/CZ language)

We go to es_extended --> client --> functions.lua
We look for this function: function ESX.ShowNotification
We rewrite the entire function to:

![Snímek obrazovky 2023-07-24 212500](https://github.com/Mxthesss/MX-CarLock/assets/99074840/c7f7a83d-fc51-4565-8d76-5b26dac063ae)


Then you go to fxmanifest.lua in es_extended where you add this line to the shared_scripts section:

    `'@ox_lib/init.lua',`


## Usage

Once MX-CarLock is installed and configured, you can use the following key bindings in your FiveM server:

- By pressing F10 you can lock/unlock your vehicle. You have to own the vehicle, otherwise it won't work ;)

## Contributing

- Contributions to MX-CarLock are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request in the [GitHub repository](https://github.com/Mxthesss/MX-CarLock).

- Or join my discord server ;) [Discord](https://dsc.gg/mxthessdev)

## License

MX-CarLock is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Screenshots

![image](https://github.com/Mxthesss/MX-CarLock/assets/99074840/bc22c1ab-2e8a-47b9-9fbe-0a8fdd9ffbd3)

![carlockmonitor](https://github.com/Mxthesss/MX-CarLock/assets/99074840/58910315-466e-4e53-8822-c4908bcccbc9)

