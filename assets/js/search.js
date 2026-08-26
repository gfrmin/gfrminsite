/* Client-side search over the corpus at /search-index.json (see
   layouts/index.searchindex.json and the SearchIndex output format in hugo.toml).

   Two decisions worth keeping:

   The corpus is fetched on the first focus of the box, not on page load, so a
   reader who never searches pays nothing for it. The fetch is started on focus
   rather than on the first keystroke so the download overlaps with the typing.

   The control ships with the `hidden` attribute set and is revealed here. Without
   JavaScript there is no working search, and a dead input is worse than none — the
   archive and the category index are the no-JS discovery path.

   No index structure, no stemmer, no library: 37 posts scored by substring match
   over four fields is both instant and, at this size, better than a stemmer would
   be, because the queries that matter here are proper nouns. */
(function () {
  'use strict';

  var box = document.querySelector('[data-search]');
  if (!box || !window.fetch) { return; }

  var input = box.querySelector('.site-search-input');
  var panel = document.querySelector('[data-search-results]');
  var list = document.querySelector('[data-search-list]');
  var summary = panel && panel.querySelector('.search-summary');
  var hideSel = box.getAttribute('data-search-hide');
  var hidden = hideSel ? document.querySelectorAll(hideSel) : [];
  var url = box.getAttribute('data-search-index');

  var strings = { none: 'No matches.', one: '1 result', many: '{n} results', min: '{n} min' };
  try { strings = JSON.parse(box.getAttribute('data-search-strings')); } catch (e) { /* defaults */ }

  var corpus = null;
  var pending = null;

  /* Latin combining marks only (U+0300-U+036F), so Hebrew points are untouched. */
  function fold(s) {
    return String(s).toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  }

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function escRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

  function load() {
    if (pending) { return pending; }
    pending = fetch(url)
      .then(function (r) { return r.ok ? r.json() : { posts: [] }; })
      .then(function (data) {
        corpus = (data.posts || []).map(function (p) {
          p._t = fold(p.t);
          p._d = fold(p.d);
          p._m = fold((p.c || []).join(' ') + ' ' + (p.s || ''));
          p._b = fold(p.b);
          return p;
        });
        return corpus;
      })
      .catch(function () { corpus = []; return corpus; });
    return pending;
  }

  function score(post, terms) {
    var total = 0;
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i];
      var n = 0;
      if (post._t.indexOf(t) > -1) { n += post._t.indexOf(t) === 0 ? 12 : 8; }
      if (post._d.indexOf(t) > -1) { n += 3; }
      if (post._m.indexOf(t) > -1) { n += 2; }
      if (post._b.indexOf(t) > -1) { n += 1; }
      if (n === 0) { return 0; }   /* every term must land somewhere */
      total += n;
    }
    return total;
  }

  function mark(text, re) {
    return esc(text).replace(re, '<mark>$&</mark>');
  }

  /* A window of body text around the first hit, so the reader can see why a post
     matched. Falls back to the post's own description when the hit is in the title
     or the metadata. */
  function snippet(post, terms) {
    var at = -1, i;
    for (i = 0; i < terms.length && at < 0; i++) { at = post._b.indexOf(terms[i]); }
    if (at < 0) { return post.d; }
    var from = Math.max(0, at - 80);
    var text = post.b.slice(from, from + 220);
    if (from > 0) { text = '…' + text.replace(/^\S*\s/, ''); }
    if (from + 220 < post.b.length) { text = text.replace(/\s\S*$/, '') + '…'; }
    return text;
  }

  function render(query) {
    var terms = fold(query).split(/\s+/).filter(Boolean);
    var re = new RegExp('(' + terms.map(escRe).join('|') + ')', 'gi');

    var found = corpus
      .map(function (p) { return { p: p, s: score(p, terms) }; })
      .filter(function (h) { return h.s > 0; })
      .sort(function (a, b) { return b.s - a.s || (a.p.n < b.p.n ? 1 : -1); });

    /* The count is of everything that matched, not of what is drawn — a cap that
       silently rounds "31 results" down to the cap is a lie about the corpus. The
       cap is above the corpus size, so today it never bites. */
    summary.textContent = found.length === 0 ? strings.none
      : found.length === 1 ? strings.one
      : strings.many.replace('{n}', found.length);

    var hits = found.slice(0, 50);

    list.innerHTML = hits.map(function (h) {
      var p = h.p;
      return '<article class="post-card"><div class="post-card-body">'
        + '<h2 class="listing-title"><a href="' + esc(p.u) + '">' + mark(p.t, re) + '</a></h2>'
        + '<p class="listing-description">' + mark(snippet(p, terms), re) + '</p>'
        + '<div class="metadata"><time datetime="' + esc(p.n) + '">' + esc(p.dm) + '</time>'
        + '<span class="reading-time">' + esc(strings.min.replace('{n}', p.r)) + '</span>'
        + (p.s ? '<span class="meta-series">' + esc(p.s) + '</span>' : '')
        + '</div></div></article>';
    }).join('');
  }

  function show(on) {
    panel.hidden = !on;
    for (var i = 0; i < hidden.length; i++) { hidden[i].hidden = on; }
  }

  function run() {
    var query = input.value.trim();
    remember(query);
    if (query.length < 2) { show(false); return; }
    load().then(function () {
      if (input.value.trim() !== query) { return; }   /* a later keystroke won */
      render(query);
      show(true);
    });
  }

  /* Keep the query in the address bar so a search can be linked or reloaded,
     without adding a history entry per keystroke. */
  function remember(query) {
    if (!window.history || !history.replaceState) { return; }
    var u = new URL(window.location.href);
    if (query) { u.searchParams.set('q', query); } else { u.searchParams.delete('q'); }
    history.replaceState(null, '', u.pathname + u.search + u.hash);
  }

  var timer;
  input.addEventListener('input', function () {
    clearTimeout(timer);
    timer = setTimeout(run, 120);
  });
  input.addEventListener('focus', load, { once: true });
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') { input.value = ''; run(); input.blur(); }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key !== '/' || e.metaKey || e.ctrlKey || e.altKey) { return; }
    var el = document.activeElement;
    if (el && /^(INPUT|TEXTAREA|SELECT)$/.test(el.tagName)) { return; }
    if (el && el.isContentEditable) { return; }
    e.preventDefault();
    input.focus();
  });

  box.hidden = false;

  var initial = new URLSearchParams(window.location.search).get('q');
  if (initial) { input.value = initial; run(); }
})();
