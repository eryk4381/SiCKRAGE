# Author: echel0n <echel0n@sickrage.ca>
# URL: https://sickrage.ca
# Git: https://git.sickrage.ca/SiCKRAGE/sickrage.git
#
# This file is part of SickRage.
#
# SickRage is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SickRage is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SickRage.  If not, see <http://www.gnu.org/licenses/>.

from __future__ import unicode_literals

from trakt import Trakt

import sickrage


class srTraktAPI(object):
    def __init__(self):
        # Set trakt app id
        Trakt.configuration.defaults.app(
            id=sickrage.app.config.trakt_app_id
        )

        # Set trakt client id/secret
        Trakt.configuration.defaults.client(
            id=sickrage.app.config.trakt_api_key,
            secret=sickrage.app.config.trakt_api_secret
        )

        # Bind trakt events
        Trakt.on('oauth.token_refreshed', self.on_token_refreshed)

        Trakt.configuration.defaults.oauth(
            refresh=True
        )

        if sickrage.app.config.trakt_oauth_token:
            Trakt.configuration.defaults.oauth.from_response(
                sickrage.app.config.trakt_oauth_token
            )

    @staticmethod
    def authenticate(pin):
        # Exchange `code` for `access_token`
        sickrage.app.config.trakt_oauth_token = Trakt['oauth'].token_exchange(pin, 'urn:ietf:wg:oauth:2.0:oob')
        if not sickrage.app.config.trakt_oauth_token:
            return False

        sickrage.app.log.debug('Token exchanged - auth: %r' % sickrage.app.config.trakt_oauth_token)
        sickrage.app.config.save()

        return True

    @staticmethod
    def on_token_refreshed(response):
        # OAuth token refreshed, save token for future calls
        sickrage.app.config.trakt_oauth_token = response

        sickrage.app.log.debug('Token refreshed - auth: %r' % sickrage.app.config.trakt_oauth_token)
        sickrage.app.config.save()

    def __getattr__(self, name):
        if hasattr(self, name):
            return super(srTraktAPI, self).__getattribute__(name)

        return getattr(Trakt, name)

    def __setattr__(self, name, value):
        if hasattr(self, name):
            return super(srTraktAPI, self).__setattr__(name, value)

        setattr(Trakt, name, value)

    def __getitem__(self, key):
        return Trakt[key]


class traktException(Exception):
    pass


class traktAuthException(traktException):
    pass


class traktServerBusy(traktException):
    pass
