#!/usr/bin/env perl

# Copyright: Newie Ventures Pty Ltd
# Author: Heath Raftery
# Created: Sept, 2018.

# Export fields and tags by executing at the influx CLI prompt:
#   SHOW TAG KEYS ON db;SHOW FIELD KEYS ON db
# Copy and paste the result into this script (eg. on macos: pbpaste | ./make_schema_table.pl > schema.csv )
# Can then be nicely formatted with column -s"," -t schema.csv

my %schema;
my $measurement;

while(<>)
{
  chomp;
  next if /fieldKey/;
  next if /tagKey/;
  next if /---/;
  $_ .= " tag" if(/^\w+$/); # Add " tag" suffix if it's only a single word on the line.
  s/name: //;
  s/ +/,/;

  # print $_ . "\n";
  # At this point the line above would produce a bunch of:
  # measurement_name
  # field_name,type (or tag_name,tag)
  # field_name,type (or tag_name,tag)
  # empty line

  # Extract values for each measurement.
  next if($_ eq ""); # skip the empty lines

  if(/^\w+$/)                             # If only a single word on the line,
  { $measurement = $_ }                   # then it's a new measurement,
  else                                    # else add value to the current measurement.
  { push(@{$schema{$measurement}}, $_); } # Note Perl automatically creates the array when necessary.
}

# Data collected, now format it. It now looks like this, when dumped with print "$_ => @{$schema{$_}}\n" for (sort keys %schema);
#   alert_req => alert_type,tag dev_eui,tag
#   recv_sms => phone,tag

# Get size of biggest measurement so we know how many rows to make
my $maxLen = 0;
for(%schema)
{
  my $len = scalar(@{$schema{$_}});
  $maxLen = $len if $len > $maxLen;
}

# Print the header row
my @measurements = sort keys %schema;
for(@measurements[0..$#measurements-1]) # all but last
{
  print $_.", ,|,"; # space instead of nothing for empty value helps column command to parse
}
print $measurements[$#measurements]."\n"; # last

# Print each subsequent row
foreach my $i (-1..$maxLen-1)
{
  my $first = 1;
  for(@measurements) # each column
  {
    $first ? $first = !$first : print ",|,"; # print seperator if not our first time through the loop

    if($i<0) # Print the delimiter row
    {
      my $maxField = length($_);
      foreach my $val (@{$schema{$_}})
      {
        my $len = index($val, ','); # length of field up to the first comma
        $maxField = $len if $len > $maxField;
      }
      print '-'x$maxField . ", ";
    }
    else # Print the row of content
    {
      print ($i < scalar(@{$schema{$_}}) ? @{$schema{$_}}[$i] : " , "); # print value if it exists, otherwise empty value
    }
  }
  print "\n";
}
