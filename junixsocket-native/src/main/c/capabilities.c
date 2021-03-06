/*
 * junixsocket
 *
 * Copyright 2009-2021 Christian Kohlschütter
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "config.h"
#include "capabilities.h"

CK_IGNORE_UNUSED_VARIABLE_BEGIN
// see AFUNIXSocketCapability.java in junixsocket-common
static int CAPABILITY_PEER_CREDENTIALS = (1 << 0);
static int CAPABILITY_ANCILLARY_MESSAGES = (1 << 1);
static int CAPABILITY_FILE_DESCRIPTORS = (1 << 2);
static int CAPABILITY_ABSTRACT_NAMESPACE = (1 << 3);
static int CAPABILITY_DATAGRAMS = (1 << 4);
static int CAPABILITY_NATIVE_SOCKETPAIR = (1 << 5);
CK_IGNORE_UNUSED_VARIABLE_END

/*
 * Class:     org_newsclub_net_unix_NativeUnixSocket
 * Method:    capabilities
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_org_newsclub_net_unix_NativeUnixSocket_capabilities(
                                                                                JNIEnv *env CK_UNUSED, jclass clazz CK_UNUSED)
{

    int capabilities = 0;

#if defined(LOCAL_PEERCRED) || defined(LOCAL_PEEREPID) || defined(LOCAL_PEEREUUID) || \
    defined(SO_PEERCRED) || defined(__NetBSD__) || defined(__sun) || defined(__sun__)
    capabilities |= CAPABILITY_PEER_CREDENTIALS;
#endif

#if defined(junixsocket_have_ancillary)
    capabilities |= CAPABILITY_ANCILLARY_MESSAGES;
    capabilities |= CAPABILITY_FILE_DESCRIPTORS;
#endif

#if defined(__linux__)
    // despite earlier claims [1], they're not supported in Windows 10 (yet) [2]
    // [1] https://devblogs.microsoft.com/commandline/af_unix-comes-to-windows/
    // [2] https://github.com/microsoft/WSL/issues/4240
    capabilities |= CAPABILITY_ABSTRACT_NAMESPACE;
#endif

#if !defined(_WIN32)
    capabilities |= CAPABILITY_DATAGRAMS;
#endif

#if !defined(_WIN32)
    capabilities |= CAPABILITY_NATIVE_SOCKETPAIR;
#endif

    return capabilities;
}
