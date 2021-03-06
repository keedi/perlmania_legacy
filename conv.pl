#!/usr/bin/env perl 
use strict;
use utf8;
use YAML;
use Data::Dump;
use 5.010;
use HTML::Entities;

my @files = <./*.xml>;

my %all;
foreach my $f (@files){
	local($/); undef($/);
	
	my @article;
	$f =~ /perlmania_dump_(.+)_utf8_1st\.xml/;
	my $key = $1;
	say $key.'...';

	open my $fh, '<:utf8', $f;
	my $xml = <$fh>;
	close $fh;

	my $cnt=4;
	my %ref;
	my @buf;
	while( $xml =~ m{<row>(.+?)</row>}gs ){
		my $row = $1;
		my %data;
		while( $row =~ m{<field name="([^"]+?)">(.*?)</field>}gs ){
			my $k = $1;
			my $v = decode_entities($2);
			$data{$k} = $v;
		}
		$ref{$data{SelfID}} = \%data; #indexing
		push(@buf, \%data);
	}
	foreach my $b (@buf){
		my %data = %{$b};
		if( $data{ParentID} ){
			my $parent = $ref{$data{ParentID}};
			if( $parent ){
				push(@{$parent->{Threads}},\%data);
				next;
			}
		}
		push(@article,\%data);
	}
	$all{$key} = \@article;
}
YAML::DumpFile('perlmania.yaml', \%all);
