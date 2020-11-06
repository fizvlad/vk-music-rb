# spec_data

This folder should contain bunch of *.response files which can be used for testing parsers and other utilities. Since return of response might contain private data this folder is git-ignored.

## List of used files

### load_section__my_audios

Can be read from `https://m.vk.com/audio?act=load_section&owner_id=#{MY_USER_ID}&playlist_id=-1&access_hash=&type=playlist&offset=0&utf8=true`

### load_section__single_data_array

Single data array from [load_section__my_audios](#load_section__my_audios)

### mobile_ajax_search

AJAX post request for search. Path: `https://m.vk.com/audio`. Form: `{ "_ajax": 1, "q": "Test" }`
