#include "ApplicationInfo.h"
#include "BuildConfig.h"

ApplicationInfo::ApplicationInfo(QObject *parent) : QObject(parent)
{
    applicationName(APPLICATION_NAME);
    versionCode(VERSION_CODE);
    versionName(VERSION_NAME);
    versionHash(VERSION_HASH);
    buildDateTime(BUILD_DATE_TIME);
    author(AUTHOR);
}

ApplicationInfo::~ApplicationInfo() = default;
