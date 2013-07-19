import os

# See "Help" section at the end for some orientation.

################################################################
# Boostrapping

env = Environment()

env['PROJECT_NAME'] = 'Discordians'

# Load machine-specific config, if it exists.  This can override defaults.
LOCAL_CONFIG_FULL_PATH = os.path.join('SConsLocal', 'Config.py')
if os.path.isfile(LOCAL_CONFIG_FULL_PATH):
    from SConsLocal.Config import Config
    Config(env)

from src.protocol23.SConsLib.Protocol23 import Protocol23
Protocol23(env)


################################################################

