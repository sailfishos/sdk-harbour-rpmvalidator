#
# Copyright (C) 2014 Jolla Ltd.
# Contact: Reto Zingg <reto.zingg@jolla.com>
#
# This file is part of the SailfishOS SDK
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

require 'zlib'

rodata_info = `objdump -h #{ARGV[0]} 2>/dev/null |grep .rodata |tr -s ' '`.split(" ")

exit if rodata_info.empty?

rodata_size = rodata_info[2].to_i(16)
rodata_address = rodata_info[5].to_i(16)

rodata = open(ARGV[0]) { |file|
        file.seek(rodata_address)
        file.read(rodata_size)
}

(rodata.size - 4).times { |position|
        segment_size = rodata[position..position+3].unpack("L>")[0]
        data = if rodata[position+4] == 'x'  # possibly compressed data
                       begin
                               Zlib::Inflate.inflate(rodata[position+4..-1])
                       rescue Zlib::DataError, Zlib::NeedDict
                       end
               end || begin                  # not compressed
                       next if segment_size > (rodata_size - position - 4)
                       next if segment_size < 7
                       rodata[position+4..position+3+segment_size]
               end
        if (data_utf8 = data.force_encoding("UTF-8")).valid_encoding? and data_utf8 =~ /^[ \t]*import[ \t]/  # sanity control
                puts "-"*120, data_utf8
        end
}
