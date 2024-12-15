#include "ApplicationInfo.h"
#include "BuildConfig.h"

ApplicationInfo::ApplicationInfo(QObject *parent) : QObject(parent)
{
    applicationName(APPLICATION_NAME);
    versionName(VERSION_NAME);
    buildDateTime(BUILD_DATE_TIME);
    author(AUTHOR);
}

ApplicationInfo::~ApplicationInfo() = default;
