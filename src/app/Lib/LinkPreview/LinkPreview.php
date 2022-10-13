<?php

namespace App\Lib\LinkPreview;

use Dusterio\LinkPreview\Client;

final class LinkPreview implements LinkPreviewInterface
{
    public function get(string $url): GetLinkPreviewResponse
    {
        // 下記のサービスでも同様のことが実現できる
        // @see https://www.linkpreview.net/
        $previewClient = new Client($url);
        $response = $previewClient->getPreview('general')->toArray();

        return new GetLinkPreviewResponse($response['title'], $response['description'], $response['corver']);
    }
}
