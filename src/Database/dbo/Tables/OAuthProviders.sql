CREATE TABLE [dbo].[OAuthProviders] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [UserId]         INT            NOT NULL,
    [Provider]       NVARCHAR (50)  NOT NULL,
    [ProviderUserId] NVARCHAR (255) NOT NULL,
    [AccessToken]    NVARCHAR (MAX) NULL,
    [RefreshToken]   NVARCHAR (MAX) NULL,
    [TokenExpiresAt] DATETIME2 (7)  NULL,
    [CreatedAt]      DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]      DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OAuthProviders_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_OAuthProviders_Provider_ProviderUserId] UNIQUE NONCLUSTERED ([Provider] ASC, [ProviderUserId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OAuthProviders_Provider_ProviderUserId]
    ON [dbo].[OAuthProviders]([Provider] ASC, [ProviderUserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OAuthProviders_UserId]
    ON [dbo].[OAuthProviders]([UserId] ASC);

