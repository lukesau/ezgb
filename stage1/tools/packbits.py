"""Run-length packing for stage1's tile data (stage1/src/video.c unpack).

A control byte c, then: c = 0 the end; c < $80, the next c bytes as they
are; c >= $80, the next byte repeated c - $7D times (3 to 130). Runs of two
aren't worth a control byte, so they go literal.
"""


def pack(d):
    out = bytearray()
    i, n = 0, len(d)
    while i < n:
        j = i
        while j + 1 < n and d[j + 1] == d[i] and j - i < 129:
            j += 1
        run = j - i + 1
        if run >= 3:
            out += bytes((0x7D + run, d[i]))
            i += run
            continue
        k = i
        while k < n and k - i < 127:
            if k + 2 < n and d[k] == d[k + 1] == d[k + 2]:
                break
            k += 1
        out += bytes((k - i,)) + bytes(d[i:k])
        i = k
    out.append(0)
    return bytes(out)


def unpack(p):
    """The inverse, for checking."""
    out = bytearray()
    i = 0
    while p[i]:
        c = p[i]
        i += 1
        if c & 0x80:
            out += bytes((p[i],)) * (c - 0x7D)
            i += 1
        else:
            out += p[i:i + c]
            i += c
    return bytes(out)


def c_array(name, data, per_line=16):
    lines = [f"const uint8_t {name}[{len(data)}] = {{"]
    for i in range(0, len(data), per_line):
        lines.append("    " + ", ".join(f"0x{b:02X}" for b in data[i:i + per_line]) + ",")
    lines.append("};")
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    import os
    import random
    for _ in range(200):
        d = bytes(random.choice((0, 0, 0, 0xFF, random.randrange(256))) for _ in range(random.randrange(300)))
        assert unpack(pack(d)) == d
    print("ok")
