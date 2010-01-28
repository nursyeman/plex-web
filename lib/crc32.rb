module Crc32
  extend self

  def crc32(buffer)
    crc = 0xFFFFFFFF

    buffer.each_byte do |value|
      crc = uint32(crc ^ (value << 24))
      8.times do
        if (crc & 0x80000000).nonzero?
          crc = uint32((crc << 1) ^ 0x04C11DB7)
        else
          crc = uint32(crc << 1)
        end
      end
    end

    return crc
  end

private

  def uint32(n)
    n % (1 << 32)
  end
end