<?php

namespace App\Lib\LinkPreview;

final class GetLinkPreviewResponse
{
    public string $title;
    public string $description;
    public string $corver;

    public function __construct(string $title, string $description, string $corver)
    {
        $this->title = $title;
        $this->description = $description;
        $this->corver = $corver;
    }
}
