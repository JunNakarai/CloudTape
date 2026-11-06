# CloudTape 1.0.2 Release Notes Draft

## Japanese — App Store “What’s New”

お気に入り機能を追加しました。

- 曲のハートを押して、お気に入りを登録・解除できます。
- お気に入りの曲をライブラリの先頭に表示します。
- ランダム再生では、お気に入りの曲をシャッフルで一巡してから、それ以外の曲をシャッフルで再生します。
- お気に入りはアプリを再起動しても保持されます。

## English — App Store “What’s New”

Favorites are now available.

- Tap a track’s heart to add or remove it from favorites.
- Favorite tracks appear at the top of your library.
- Random playback shuffles through your favorites first, then shuffles through the remaining tracks.
- Your favorites are saved between app launches.

## TestFlight — What to Test

- Add and remove favorites, then relaunch to confirm the selection is saved.
- Confirm favorite tracks appear first, including in search results.
- Start random playback with no favorites, some favorites, and all tracks marked as favorites. Each track should appear once in a forward pass, with all favorites before the rest.
- Change favorites during playback: the list should update immediately, while the existing queue stays unchanged until a new queue starts.
- Check normal track selection, next/previous, background playback, and the optional support purchase.
