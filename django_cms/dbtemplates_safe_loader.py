
import dbtemplates.loader
import django.db.utils


class Loader(dbtemplates.loader.Loader):
    def get_contents(self, origin):
        try:
            return super(Loader, self).get_contents(origin)
        except django.db.utils.ProgrammingError:
            return None
