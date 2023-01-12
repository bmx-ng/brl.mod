/*
ISC License

Copyright (c) 2023, Bruce A Henderson

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
*/
#include "mapbox/earcut.hpp"

extern "C" {

#include "brl.mod/blitz.mod/blitz.h"

    struct SVec2I {
        int x;
        int y;
    };

    struct SVec2F {
        float x;
        float y;
    };

    BBArray * bmx_polygon_tri_svec2i(struct SVec2I * p, int size);
    BBArray * bmx_polygon_tri_svec2f(struct SVec2F * p, int size);
}

namespace mapbox {
namespace util {

template <>
struct nth<0, struct SVec2I> {
    inline static int get(const struct SVec2I &v) {
        return v.x;
    };
};
template <>
struct nth<1, struct SVec2I> {
    inline static int get(const struct SVec2I &v) {
        return v.y;
    };
};

template <>
struct nth<0, struct SVec2F> {
    inline static float get(const struct SVec2F &v) {
        return v.x;
    };
};
template <>
struct nth<1, struct SVec2F> {
    inline static float get(const struct SVec2F &v) {
        return v.y;
    };
};

} // namespace util
} // namespace mapbox

BBArray * bmx_polygon_tri_svec2i(struct SVec2I * p, int size) {

    std::vector<struct SVec2I> points(p, p + size);
    std::vector<std::vector<struct SVec2I>> polygon;
    polygon.push_back(points);

    std::vector<int> indices = mapbox::earcut<int>(polygon);

    BBArray *arr = bbArrayNew1DNoInit("i", indices.size());

	int *s = (int*)BBARRAYDATA(arr,arr->dims);

    std::copy(indices.begin(), indices.end(), s);

    return arr;
}

BBArray * bmx_polygon_tri_svec2f(struct SVec2F * p, int size) {

    std::vector<struct SVec2F> points(p, p + size);
    std::vector<std::vector<struct SVec2F>> polygon;
    polygon.push_back(points);

    std::vector<int> indices = mapbox::earcut<int>(polygon);

    BBArray *arr = bbArrayNew1DNoInit("f", indices.size());

	int *s = (int*)BBARRAYDATA(arr,arr->dims);

    std::copy(indices.begin(), indices.end(), s);

    return arr;
}