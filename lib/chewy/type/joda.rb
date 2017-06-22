module Chewy
  class Type
    class Joda
      JODA_TO_RUBY_MAPPING = {
        /G+/ => '', # era is unsupported
        /C+/ => '%C',
        /Y{3,}|y{3,}|Y|y/ => '%y',
        /YY|yy/ => '%Y',
        /x+/ => '%G',
        /w/ => '%-V',
        /ww+/ => '%V',
        /e+/ => '%u',
        /E{,3}/ => '%a',
        /E{4,}/ => '%A',
        /D{,2}/ => '%-j',
        /D{3,}/ => '%j',
        /M/ => '%-m',
        /MM/ => '%m',
        /MMM/ => '%b',
        /M{4,}/ => '%B',
        /d/ => '%-d',
        /dd+/ => '%d',
        /a+/ => '%p',
        /K/ => '', # hour of halfday (0~11) is unsupported
        /h/ => '%-I',
        /hh+/ => '%I',
        /H/ => '%-H',
        /HH+/ => '%H',
        /k/ => '', # clockhour of day (1~24) is unsupported
        /m/ => '%-M',
        /mm+/ => '%M',
        /s/ => '%-S',
        /ss+/ => '%S',
        /S+/ => '%N',
        /z{,3}/ => '%Z',
        /z{4,}/ => '', # Not supported
        /Z/ => '%z',
        /ZZ/ => '%:z',
        /ZZ{3,}/ => '' # Not supported
      }.freeze
    end
  end
end
