CREATE TABLE [dbo].[UserPreferences] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [UserId]             INT           NOT NULL,
    [EmailNotifications] BIT           DEFAULT ((1)) NOT NULL,
    [PushNotifications]  BIT           DEFAULT ((1)) NOT NULL,
    [SmsNotifications]   BIT           DEFAULT ((0)) NOT NULL,
    [EventReminders]     BIT           DEFAULT ((1)) NOT NULL,
    [AnnouncementAlerts] BIT           DEFAULT ((1)) NOT NULL,
    [DiscussionUpdates]  BIT           DEFAULT ((1)) NOT NULL,
    [Theme]              NVARCHAR (20) DEFAULT ('light') NOT NULL,
    [Language]           NVARCHAR (10) DEFAULT ('en') NOT NULL,
    [CreatedAt]          DATETIME2 (7) DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]          DATETIME2 (7) DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserPreferences_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProfiles] ([Id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([UserId] ASC)
);

