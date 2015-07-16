package MFST::Skating::Data;
use Moo;
my $DEBUG = $ENV{DEBUG} || 0;

use Types::Standard qw/:all/;

use List::Util qw/sum0/;
use Test::Deep::NoTest qw/eq_deeply/;
use Text::ASCIITable;

if ($DEBUG) { use Data::Dumper; };

has competitors => (
    is => "ro",
    isa => ArrayRef[Str],
    required => 1,
);

has max_place => (
    is => "lazy",
    isa => Int,
);
sub _build_max_place {
    my $self = shift;
    return scalar @{$self->competitors};
}

has _real_max_place => (
    is => "lazy",
    isa => Int,
);
sub _build__real_max_place {
    my $self = shift;
    my $max = 1;
    do { $max = $max < $_ ? $_ : $max for @$_ } for values %{$self->data};
    return $max;
}

has data => (
    is => "ro",
    isa => HashRef[ArrayRef[Int]],
    required => 1,
);

has 'judges' => (
    is => "lazy",
    isa => ArrayRef[Str],
);
sub _build_judges {
    my $self = shift;
    return [sort keys %{$self->data}];
}

has '_c_data' => (
    is => "lazy",
    isa => HashRef[HashRef[Int]],
);
sub _build__c_data {
    my $self = shift;

    my $res = {};
    for my $i ( 0 .. ($self->max_place - 1) ) {
        for my $j ( @{ $self->judges } ) {
            $res->{ $self->competitors->[$i] }->{$j} = $self->data->{$j}->[$i];
        }
    }

    return $res;
}

has '_j_data' => (
    is => "lazy",
    isa => HashRef[HashRef[Int]],
);
sub _build__j_data {
    my $self = shift;

    my $res = {};
    for my $j ( @{ $self->judges } ) {
        for my $i ( 0 .. ($self->max_place - 1) ) {
            $res->{$j}->{ $self->competitors->[$i] } = $self->data->{$j}->[$i];
        }
    }

    return $res;
}

has result => (
    is => "lazy",
    isa => HashRef[Int],
    clearer => "clear_result",
    default => sub { {} }
);

has 'table' => (
    is => "lazy",
    isa => HashRef[HashRef[HashRef[Int]]],
    clearer => "clear_table"
);
sub _build_table {
    my $self = shift;
    my $table = { map { ("1-$_" => {}) } (1 .. $self->max_place) };
    return $table;
}

sub debug {
    warn(@_) if $DEBUG;
}

sub to_s {
    my $self = shift;

    my $t = Text::ASCIITable->new;
    my @tcols = $DEBUG ? sort { eval("$b") <=> eval("$a") } keys %{$self->table} : ();
    $t->setCols( "Compt/Judge", @{ $self->judges }, "*", @tcols, "*", "Result" );
    do { my $c = $_; $t->addRow(
            $c, (map {
                $self->_j_data->{$_}->{$c}
            } @{$self->judges}), "*",
            (
                map {
                    my $info = $self->table->{$_}->{$c};
                    ($info && $info->{count})
                        ? "$info->{count}($info->{sum})" . ( $info->{count}*2 > @{$self->competitors} ? "!" : "")
                        : ""
                } @tcols
            ),
            "*",
            $self->result->{$c} // "?"
    ) } for @{ $self->competitors };

    "$t";
}

sub check_data {
    my $self = shift;

    for my $judge ( @{$self->judges} ) {
        my $scores = $self->data->{$judge};
        die "No scores for $judge" unless $scores;

        my $uniq_scores = { map { $_ => 1 } @$scores };
        die "Wrong scores for $judge: " . join(", ", map { $_ // '?' } @$scores) unless keys %$uniq_scores == @{$self->competitors};
    }
}

sub compute {
    my $self = shift;
    $self->clear_result;
    $self->clear_table;
    $self->check_data;

    my $table = $self->table;
    my $res = $self->result;

    my $place = 1;
    for my $col ( 1 .. $self->_real_max_place ) {
        my $tcol = $table->{ "1-$col" };
        # count
        debug("Checking col: $col");
        my $majority = [];
        my $majority_by_uid = {};
        for my $c ( @{ $self->competitors } ) {
            next if $res->{$c};

            my @restricted_marks = grep { $_ <= $col } values %{ $self->_c_data->{$c} };
            $tcol->{$c} = { count => scalar @restricted_marks, sum => sum0(@restricted_marks) };
            $tcol->{$c}->{uid} = "$tcol->{$c}->{count}($tcol->{$c}->{sum})";
            debug("1-$col :: $c = $tcol->{$c}->{count} ($tcol->{$c}->{sum} :: [" . join(", ", @restricted_marks) . "])");

            if ($tcol->{$c}->{count} > (@{$self->judges} / 2.0)) {
                push @$majority, $c;
                push @{$majority_by_uid->{ $tcol->{$c}->{uid} }}, $c;
            }
        }

        debug("Majority: " . join(", ", @$majority));
        debug("Majority by UID: " . Dumper($majority_by_uid));
        #rule5
        if (@$majority >= 1) {
            my @cmax = sort {
                $tcol->{$a}->{count} == $tcol->{$b}->{count}
                ? $tcol->{$a}->{sum} <=> $tcol->{$b}->{sum}
                : $tcol->{$b}->{count} <=> $tcol->{$a}->{count}
            } @$majority;

            for my $c ( @cmax ) {
                next if $res->{$c};
                my $muid = $majority_by_uid->{ $tcol->{$c}->{uid} };
                if ( @$muid == 1 ) {
                    $res->{ $c } = $place++;
                } elsif ( @$muid > 1 ) {
                    debug(">> muid, competitors\n\t" . Dumper([$muid, $self->competitors]));
                    if ( eq_deeply( [ sort @$muid ] , [ sort @{$self->competitors} ] ) ) {
                        last if $col < $self->_real_max_place;

                        my $avg_place = $place + ( @$muid - 1 ) / 2;
                        do { $res->{$_} = $avg_place; $place++ } for @$muid;
                    } else {
                        my $restricted_data = MFST::Skating::Data->new(
                            competitors => [ @$muid ],
                            data => {
                                map { my $j = $_; $j => [ map { $self->_j_data->{$j}->{$_} } @$muid ] } @{$self->judges}
                            }
                        );
                        debug("We need to GO DEEPER!: " . Dumper( $restricted_data ));

                        my $rres = $restricted_data->compute;

                        debug("Restricted result: " . Dumper( $rres ));
                        if (keys %$rres == @$muid) {
                            my @rmax = sort { $rres->{$a} <=> $rres->{$b} } keys %$rres;
                            my $start_place = $place - 1;
                            do { $res->{ $_ } = $start_place + $rres->{$_}; $place++ } for @rmax;
                        } else {
                            die "strange 1";
                        }
                    }
                } else {
                    die "strange";
                }
            } # for
        }
    }

    return $res;
}

1;
