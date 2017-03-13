#!/bin/bash
#
# Build script
#
###########################################################

DOCKER_LOG=/var/log/docker.log
DEBUG_LOG=/dev/null
if [ "$DEBUG" = true ]; then
  DEBUG_LOG=$DOCKER_LOG
fi

# cd to working directory
cd $SRC_DIR

# If the source directory is empty
if ! [ "$(ls -A $SRC_DIR)" ]; then
    # Initialize repository
    echo ">> [$(date)] Initializing repository" >> $DOCKER_LOG
    yes | repo init -u git://github.com/lineageos/android.git -b cm-13.0 2>&1 >&$DEBUG_LOG
fi

# Copy local manifests to the appropriate folder in order take them into consideration
echo ">> [$(date)] Copying '$LMANIFEST_DIR/*.xml' to '$SRC_DIR/.repo/local_manifests/'" >> $DOCKER_LOG
cp $LMANIFEST_DIR/*.xml $SRC_DIR/.repo/local_manifests/ >&$DEBUG_LOG

# Go to "vendor/cm" and reset it's current git status ( remove previous changes ) only if the directory exists
if [ -d "vendor/cm" ]; then
    cd vendor/cm
    git reset --hard 2>&1 >&$DEBUG_LOG
    cd $SRC_DIR
fi

# Sync the source code
echo ">> [$(date)] Syncing repository" >> $DOCKER_LOG
repo sync 2>&1 >&$DEBUG_LOG

# If requested, clean the OUT dir in order to avoid clutter
if [ "$CLEAN_OUTDIR" = true ]; then
    echo ">> [$(date)] Cleaning '$ZIP_DIR'" >> $DOCKER_LOG
    cd $ZIP_DIR
    rm *
    cd $SRC_DIR
fi

# Prepare the environment
echo ">> [$(date)] Preparing build environment" >> $DOCKER_LOG
source build/envsetup.sh 2>&1 >&$DEBUG_LOG


# Start the build
echo ">> [$(date)] Starting build for maguro" >> $DOCKER_LOG
if brunch maguro 2>&1 >&$DEBUG_LOG; then
    # Move produced ZIP files to the main OUT directory
    echo ">> [$(date)] Moving build artifacts for maguro to '$ZIP_DIR'" >> $DOCKER_LOG
    cd $SRC_DIR
    find out/target/product/maguro -name '*UNOFFICIAL*.zip*' -exec mv {} $ZIP_DIR \; >&$DEBUG_LOG
else
    echo ">> [$(date)] Failed build for maguro" >> $DOCKER_LOG
fi
# Clean everything, in order to start fresh on next build
if [ "$CLEAN_AFTER_BUILD" = true ]; then
    echo ">> [$(date)] Cleaning build for maguro" >> $DOCKER_LOG
    make clean 2>&1 >&$DEBUG_LOG
fi
echo ">> [$(date)] Finishing build for maguro" >> $DOCKER_LOG

# Clean the src directory if requested
if [ "$CLEAN_SRCDIR" = true ]; then
    rm -Rf "$SRC_DIR/*"
fi
