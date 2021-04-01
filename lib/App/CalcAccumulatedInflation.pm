package App::CalcAccumulatedInflation;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{calc_accumulated_inflation} = {
    v => 1.1,
    summary => 'Calculate accumulated inflation (or savings rate, etc) over the years',
    description => <<'_',

This routine generates a table of accumulated inflation over a period of several
years. You can either specify a fixed rate for every years (`yearly_rate`), or
specify each year's rates (`rates`). You can also optionally set base index
(default to 1) and base year (default to 0).

_
    args => {
        years => {
            schema => ['int*', min=>0],
            default => 10,
        },
        rates => {
            summary => 'Different rates for each year, in percent',
            schema  => ['array*', of=>'float*', min_len=>1, 'x.perl.coerce_rules'=>['From_str::comma_sep']],
        },
        yearly_rate => {
            summary => 'A single rate for every year, in percent',
            schema => 'float*',
            cmdline_aliases => {y=>{}},
        },
        base_index => {
            schema => 'float*',
            default => 1,
        },
        base_year => {
            schema => 'float*',
            default => 0,
        },
    },
    args_rels => {
        req_one => ['rates', 'yearly_rate'],
    },
    examples => [
        {
            summary => 'See accumulated 6%/year inflation for 10 years',
            args => {yearly_rate=>6},
        },
        {
            summary => 'See accumulated 5.5%/year inflation for 7 years',
            args => {yearly_rate=>5.5, years=>7},
        },
        {
            summary => "Indonesia's inflation rate for 2003-2014",
            args => {rates=>[5.16, 6.40, 17.11, # 2003-2005
                             6.60, 6.59, 11.06, 2.78, 6.96, # 2006-2010
                             3.79, 4.30, 8.38, 8.36, # 2011-2014
                         ]},
        },
        {
            summary => 'How much will your $100,000 grow over the next 10 years, if the savings rate is 4%; assuming this year is 2021',
            args => {yearly_rate=>4, years=>10, base_year=>2021, base_index=>100000},
        },
    ],
    result_naked => 1,
};
sub calc_accumulated_inflation {
    my %args = @_;

    my $index = $args{base_index} // 1;
    my $year = $args{base_year} // 0;
    my @res = ({year=>$year, index=>$index});

    my $i = 0;
    if (defined $args{yearly_rate}) {
        while ($i++ < $args{years}) {
            $year++;
            $index *= 1 + $args{yearly_rate}/100;
            push @res, {
                year  => $year,
                index => sprintf("%.4f", $index),
            };
        }
    } else {
        my $rates = $args{rates};
        while ($i++ <= $#{$rates}) {
            my $rate = $rates->[$year];
            $index *= 1 + $rate/100;
            $year++;
            push @res, {
                year  => $year,
                rate  => sprintf("%.2f%%", $rate),
                index => sprintf("%.4f", $index),
            };
        }
    }

    \@res;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<calc-accumulated-inflation>.

=cut
