<?php

namespace Tests\Feature\Bookmarks;

use App\Bookmark\UseCase\CreateBookmarkUseCase;
use App\Lib\LinkPreview\LinkPreviewInterface;
use App\Lib\LinkPreview\MockLinkPreview;
use App\Models\BookmarkCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class CreateBookmarkUseCaseTest extends TestCase
{
    private CreateBookmarkUseCase $useCase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->app->bind(LinkPreviewInterface::class, MockLinkPreview::class);

        $this->useCase = $this->app->make(CreateBookmarkUseCase::class);
    }

    public function testSaveCorrectData()
    {
        // 念のため絶対に存在しないURL（example.comは使えないドメインなので）を使う
        $url = 'https://notfound.example.com/';
        $category = BookmarkCategory::query()->first()->id;
        $comment = 'テスト用のコメント';

        // ログインしないと失敗するので強制ログイン
        $testUser = User::query()->first();
        Auth::loginUsingId($testUser->id);

        $this->useCase->handle($url, $category, $comment);

        Auth::logout();

        // データベースに保存された値を期待したとおりかどうかチェックする
        $this->assertDatabaseHas('bookmarks', [
            'url' => $url,
            'category_id' => $category,
            'user_id' => $testUser->id,
            'comment' => $comment,
            'page_title' => 'モックのtitle',
            'page_description' => 'モックのdescription',
            'page_thumbnail_url' => 'https://i.gyazo.com/634f77ea66b5e522e7afb9f1d1dd75cb.png',
        ]);
    }

    public function testWhenFetchMetaFailed()
    {
        $url = 'https://notfound.example.com/';
        $category = BookmarkCategory::query()->first()->id;
        $comment = 'テスト用のコメント';

        // これまでと違ってMockeryというライブラリでモックを用意する
        $mock = \Mockery::mock(LinkPreviewInterface::class);

        // 作ったモックがgetメソッドを実行したら必ず例外を投げるように仕込む
        $mock->shouldReceive('get')
            ->withArgs([$url])
            ->andThrow(new \Exception('URLからメタ情報の取得に失敗'))
            ->once();

        // サービスコンテナに$mockを使うように命令する
        $this->app->instance(LinkPreviewInterface::class, $mock);


        // 例外が投げられることのテストは以下のように書く
        $this->expectException(ValidationException::class);
        $this->expectExceptionObject(ValidationException::withMessages([
            'url' => 'URLが存在しない等の理由で読み込めませんでした。変更して再度投稿してください'
        ]));

        // 仕込みが終わったので実際の処理を実行
        $this->useCase = $this->app->make(CreateBookmarkUseCase::class);
        $this->useCase->handle($url, $category, $comment);
    }
}
