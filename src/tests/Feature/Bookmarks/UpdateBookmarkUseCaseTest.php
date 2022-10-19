<?php

namespace Tests\Feature\Bookmarks;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Str;
use Tests\TestCase;

class UpdateBookmarkUseCaseTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // このミドルウェアがあると419で失敗するし、今回テストしたいことではないので外す
        $this->withoutMiddleware(VerifyCsrfToken::class);
    }

    /**
     * ユーザー認証済み
     * ユーザーIDが作成者と一致
     * 投稿内容がバリデーション通る
     *
     * →保存まで成功する
     * @dataProvider updateBookmarkPutDataProvider
     */
    public function testUpdateCorrect(?string $comment, ?int $category, string $result, array $sessionError)
    {
        $user = User::query()->find(1);
        /**
         * fromでどのURLからリクエストされたかを仮想的に設定できる
         */
        $response = $this->actingAs($user)->from('/bookmarks/create')->put('/bookmarks/1', [
            'comment' => $comment,
            'category' => $category,
        ]);

        /**
         * データプロバイダー側の結果指定に応じてアサートする内容を変える
         */
        if ($result === 'success') {
            $response->assertRedirect('/bookmarks');
            $this->assertDatabaseHas('bookmarks', [
                'id' => 1,
                'comment' => $comment,
                'category_id' => $category,
            ]);
        }
        if ($result === 'error') {
            // Formで失敗したときって元のページに戻りますよね
            $response->assertRedirect('/bookmarks/create');
            /**
             * @see https://readouble.com/laravel/6.x/ja/http-tests.html#assert-session-has-errors
             * @see https://qiita.com/iakio/items/f7a1064235c39db3f392
             */
            $response->assertSessionHasErrors($sessionError);
            $this->assertDatabaseMissing('bookmarks', [
                'id' => 1,
                'comment' => $comment,
                'category_id' => $category,
            ]);
        }
    }

    /**
     * データプロバイダ
     * @see https://phpunit.readthedocs.io/ja/latest/writing-tests-for-phpunit.html#writing-tests-for-phpunit-data-providers
     *
     * @return array
     */
    public function updateBookmarkPutDataProvider()
    {
        return [
            // $comment, $category, $result(success || error), $sessionError
            [Str::random(10), 1, 'success', []],
            [Str::random(9), 1, 'error', ['comment']],
            [Str::random(1000), 1, 'success', []],
            [Str::random(1001), 1, 'error', ['comment']],
            [Str::random(10), 0, 'error', ['category']],
            [Str::random(9), 0, 'error', ['comment', 'category']],
            [null, 1, 'error', ['comment']],
            [Str::random(10), null, 'error', ['category']],
            [null, null, 'error', ['comment', 'category']],
        ];
    }

    /**
     * ユーザーが未認証
     *
     * →ログインページへのリダイレクト
     */
    public function testFailedWhenLogoutUser()
    {
        $this->put('/bookmarks/1', [
            'comment' => 'ブックマークのテスト用のコメントです',
            'category' => 1,
        ])->assertRedirect('/login');
    }

    /**
     * ログインはしているが他人による実行
     *
     * →ステータス403で失敗
     */
    public function testFailedWhenOtherUser()
    {
        $user = User::query()->find(2);
        $this->actingAs($user)->put('/bookmarks/1', [
            'comment' => 'ブックマークのテスト用のコメントです',
            'category' => 1,
        ])->assertForbidden();
    }
}
