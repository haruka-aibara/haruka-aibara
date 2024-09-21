## コミットしたユーザ情報の変更
git filter-branch --force --env-filter '
        # GIT_AUTHOR_NAMEの書き換え
        if [ "$GIT_AUTHOR_NAME" = "OLD_NAME" ];
        then
                GIT_AUTHOR_NAME="NEW_NAME";
        fi
        # GIT_AUTHOR_EMAILの書き換え
        if [ "$GIT_AUTHOR_EMAIL" = "OLD_EMAIL_ADDRESS" ];
        then
                GIT_AUTHOR_EMAIL="NEW_EMAIL_ADDRESS";
        fi
        # GIT_COMMITTER_NAMEの書き換え
        if [ "$GIT_COMMITTER_NAME" = "OLD_NAME" ];
        then
                GIT_COMMITTER_NAME="NEW_NAME";
        fi
        # GIT_COMMITTER_EMAILの書き換え
        if [ "$GIT_COMMITTER_EMAIL" = "OLD_EMAIL_ADDRESS" ];
        then
                GIT_COMMITTER_EMAIL="NEW_EMAIL_ADDRESS";
        fi
        ' -- --all
        